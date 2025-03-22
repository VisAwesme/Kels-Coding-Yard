import sys
from PyQt6.QtWidgets import QApplication, QMainWindow, QListWidget, QStackedWidget, QHBoxLayout, QWidget
# Import the custom page creators
from linux_defender_gui_misc import create_scan_options_page, create_update_signatures_page, create_settings_page

class MainWindow(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Linux Defender")
        self.resize(800, 600)
        
        # Main container widget and layout
        central_widget = QWidget()
        self.setCentralWidget(central_widget)
        main_layout = QHBoxLayout()
        central_widget.setLayout(main_layout)
        
        # Left "dropdown-like" navigation (using a list widget)
        self.nav_list = QListWidget()
        self.nav_list.addItem("Scan Options")
        self.nav_list.addItem("Update Signatures")
        self.nav_list.addItem("Settings")
        self.nav_list.currentRowChanged.connect(self.display_page)
        main_layout.addWidget(self.nav_list, 1)  # 1: small portion for nav
        
        # Central area: a stacked widget to switch between pages
        self.stack = QStackedWidget()
        self.stack.addWidget(create_scan_options_page())
        self.stack.addWidget(create_update_signatures_page())
        self.stack.addWidget(create_settings_page())
        main_layout.addWidget(self.stack, 3)  # 3: gives central area more room
        
        # Start with the first page selected
        self.nav_list.setCurrentRow(0)
        
    def display_page(self, index):
        self.stack.setCurrentIndex(index)

if __name__ == "__main__":
    app = QApplication(sys.argv)
    window = MainWindow()
    window.show()
    sys.exit(app.exec())
