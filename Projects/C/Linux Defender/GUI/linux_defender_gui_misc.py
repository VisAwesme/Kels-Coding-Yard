from PyQt6.QtWidgets import QWidget, QVBoxLayout, QLabel

def create_settings_page(name):
    widget = QWidget()
    layout = QVBoxLayout()
    widget.setLayout(layout)
    
    # A simple label to indicate which page is active; add more onto this later because im just, fuckin stupid
    label = QLabel(f"Settings for {name}")
    layout.addWidget(label)
    
    # extra stuff here (buttons, checkboxes, etc.)
    return widget
