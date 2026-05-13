#include <iostream>
#include <fstream>
#include <string>
#include <fcntl.h>
#include <unistd.h>
#include <termios.h>
#include <sys/ioctl.h>
#include <cstring>
#include <ctime>

#define SYSFS_PATH "/sys/class/misc/wiite_corp_ctrl/"
#define UART_PATH "/dev/ttyS1"

// Helper: Read a value from a sysfs node
std::string read_sysfs(const std::string& node) {
    std::ifstream infile(SYSFS_PATH + node);
    std::string value;
    if (infile.is_open()) {
        std::getline(infile, value);
        infile.close();
    }
    return value;
}

// Helper: Write a value to sysfs and optionally verify the readback
bool write_sysfs(const std::string& node, const std::string& value, std::string& readback, bool verify) {
    std::string full_path = SYSFS_PATH + node;
    
    std::ofstream outfile(full_path);
    if (!outfile.is_open()) {
        std::cerr << "[ERROR] Failed to open " << full_path << " for writing.\n";
        return false;
    }
    outfile << value;
    outfile.close();

    if (verify) {
        readback = read_sysfs(node);
        if (readback.empty()) return false;
    }
    return true;
}

// Helper: Generate RTC string in format "YYYY-M-D H:M:S"
std::string get_rtc_string() {
    time_t now = time(0);
    tm *ltm = localtime(&now);
    char buffer[64]; // FIX 1: Array correctly allocated to prevent stack overflow
    snprintf(buffer, sizeof(buffer), "%d-%d-%d %d:%d:%d", 
        1900 + ltm->tm_year, 1 + ltm->tm_mon, ltm->tm_mday, 
        ltm->tm_hour, ltm->tm_min, ltm->tm_sec);
    return std::string(buffer);
}

bool init_nrf_control_plane() {
    std::string response;
    std::cout << "[INIT] Starting nRF52832 Control Plane Handshake...\n";

    // STEP 1: Enable UART Bridge and verify exact string
    if (!write_sysfs("uart_op", "1", response, true) || response != "uart enable:1") {
        std::cerr << "[ERROR] Step 1 Failed. Readback: " << response << "\n";
        return false;
    }
    std::cout << "[INIT] Step 1: uart_op = 1 (Bridge Enabled)\n";

    usleep(50000); // 50ms hardware sync delay

    // STEP 2: openUart() command sequence
    if (!write_sysfs("command", "7", response, true) || response != "1") return false;
    if (!write_sysfs("command", "8", response, true) || response != "1") return false;
    write_sysfs("command", "243", response, false); // NRF_READ_PUT_ON_STATE
    write_sysfs("command", "12", response, false);  // Read tilt last value
    write_sysfs("command", "17", response, false);  // Read silent mode
    write_sysfs("command", "13", response, false);  // Read zen mode
    std::cout << "[INIT] Step 2: Base command sequence transmitted.\n";

    // STEP 3: Sync RTC
    std::string rtc_time = get_rtc_string();
    write_sysfs("nrf_rtc", rtc_time, response, false);
    std::cout << "[INIT] Step 3: RTC synced to " << rtc_time << "\n";

    // STEP 4: Write longterm / DFU version
    std::string fw_version = read_sysfs("version");
    if (fw_version.empty()) fw_version = "48059"; // Fallback to DB known value
    write_sysfs("longterm", "9,1," + fw_version, response, false);
    std::cout << "[INIT] Step 4: Longterm DFU version " << fw_version << " set.\n";

    // STEP 5: Write btMAC
    std::string mac = read_sysfs("btMAC");
    if (mac.empty()) mac = "ca:77:87:c7:16:00"; // Fallback to DB known value
    write_sysfs("btMAC", mac, response, false);
    std::cout << "[INIT] Step 5: btMAC " << mac << " set.\n";

    // STEP 6: Write User Profile (Default: 175cm, 70kg, Age 20, Male, 10000 steps)
    write_sysfs("command", "1,175,70,20,1,10000", response, false);
    
    // STEP 7 & 8: iTime and Metric/Temper config
    write_sysfs("command", "14,0", response, false);
    write_sysfs("command", "15,1,0", response, false);
    std::cout << "[INIT] Steps 6-8: Profile and localization configs transmitted.\n";

    return true;
}

int init_nrf_data_plane() {
    std::cout << "[INIT] Opening Data Plane to hold uart_op gate: " << UART_PATH << "\n";
    
    // Open ttyS1
    int fd = open(UART_PATH, O_RDWR | O_NOCTTY);
    if (fd == -1) {
        std::cerr << "[ERROR] Unable to open UART port " << UART_PATH << "\n";
        return -1;
    }

    struct termios options;
    if (tcgetattr(fd, &options) != 0) {
        std::cerr << "[ERROR] Failed to get UART attributes: " << strerror(errno) << "\n";
        close(fd);
        return -1;
    }
    
    cfsetispeed(&options, B115200);
    cfsetospeed(&options, B115200);
    options.c_cflag &= ~PARENB;  
    options.c_cflag &= ~CSTOPB;  
    options.c_cflag &= ~CSIZE;   
    options.c_cflag |= CS8;      
    options.c_cflag |= (CLOCAL | CREAD); 
    options.c_lflag &= ~(ICANON | ECHO | ECHOE | ISIG);
    options.c_oflag &= ~OPOST;
    options.c_cc[VMIN]  = 1;
    options.c_cc[VTIME] = 0;
    
    // FIX 2: Strict tcsetattr verification block 
    if (tcsetattr(fd, TCSANOW, &options) != 0) {
        std::cerr << "[ERROR] Failed to set UART attributes: " << strerror(errno) << "\n";
        close(fd);
        return -1;
    }
    
    return fd;
}

int main() {
    // Execute the full 8-step initialization
    if (!init_nrf_control_plane()) {
        std::cerr << "[FATAL] Control plane initialization failed.\n";
        return 1;
    }
    
    // Open the UART file descriptor to lock the kernel's IRQ gate open
    int uart_fd = init_nrf_data_plane();
    if (uart_fd == -1) {
        std::cerr << "[FATAL] Data plane hold failed.\n";
        return 1;
    }

    std::cout << "[SUCCESS] Bridge Daemon initialized. Kernel IRQ 27 takes over from here.\n";
    
    // The daemon's only job now is to stay alive and hold the FD open indefinitely.
    while (true) {
        pause(); // Sleep until a signal is caught (effectively forever)
    }
    
    close(uart_fd);
    return 0;
}

--------------------------------------------------------------------------------

