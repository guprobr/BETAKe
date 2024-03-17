import os
import tkinter as tk
from tkinter import messagebox, scrolledtext
import subprocess
import threading

BETAKE_PATH = "./"

def colorize_output(text):
    # Define ANSI escape sequences for colors
    colors = {
        "red": "\033[91m",
        "green": "\033[92m",
        "yellow": "\033[93m",
        "blue": "\033[94m",
        "magenta": "\033[95m",
        "cyan": "\033[96m",
        "reset": "\033[0m"
    }

    # Apply color to the output text
    return colors["cyan"] + text + colors["reset"]

def run_shell_script():
    karaoke_name = karaoke_name_entry.get()
    video_url = video_url_entry.get()

    # Call the shell script with parameters
    script_command = ["sh", BETAKE_PATH + "betaREC.sh", karaoke_name, video_url, BETAKE_PATH]
    
    # Run the shell script in a separate thread
    threading.Thread(target=execute_shell_script, args=(script_command,), daemon=True).start()

def execute_shell_script(script_command):
    try:
        # Execute the shell script and capture the output
        process = subprocess.Popen(script_command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
        
        # Read and display output in real-time
        for line in iter(process.stdout.readline, ""):
            colored_line = colorize_output(line.strip())
            console_text.insert(tk.END, colored_line + "\n")
            console_text.see(tk.END)  # Scroll to the end of the console text widget
            
        messagebox.showinfo("Success", "Shell script executed successfully.")
    except subprocess.CalledProcessError as e:
        messagebox.showerror("Error", "Failed to execute shell script.")
    except Exception as e:
        messagebox.showerror("Error", f"An error occurred: {str(e)}")

def Terminator():
    window.destroy()
    exit()

# Create the main window
window = tk.Tk()
window.title("Karaoke Shell Interface")

# Set window size and position
window.geometry("800x640")
window.resizable(False, False)

# Customize the theme
window.configure(bg="#BABACA")
tk.Label(window, text="BETAKe Karaoke Shell Interface", bg="#f0f0f0", font=("Arial", 16)).pack(pady=10)

# Create a frame for left image
left_frame = tk.Frame(window, bg="#BABACA")
left_frame.pack(side=tk.LEFT)

# Add image on left
image_path = os.path.join(os.path.dirname(__file__), BETAKE_PATH + "tux.png")
if os.path.exists(image_path):
    try:
        img = tk.PhotoImage(file=image_path)
        img_label = tk.Label(left_frame, image=img)
        img_label.image = img  # Keep a reference to avoid garbage collection
        img_label.pack()
    except tk.TclError:
        print("Error loading image.")
else:
    print("Image file not found.")

# Create a frame for console text
console_frame = tk.Frame(window)
console_frame.pack(expand=True, fill=tk.BOTH, padx=10, pady=10)

# Create a scrolled text widget for console output
console_text = scrolledtext.ScrolledText(console_frame, wrap=tk.WORD, width=80, height=20, font=("Arial", 10))
console_text.pack(side=tk.LEFT, expand=True, fill=tk.BOTH)

# Create a frame for right image
right_frame = tk.Frame(window, bg="#BABACA")
right_frame.pack(side=tk.RIGHT)

# Add image on right
if os.path.exists(image_path):
    try:
        img = tk.PhotoImage(file=image_path)
        img_label = tk.Label(right_frame, image=img)
        img_label.image = img  # Keep a reference to avoid garbage collection
        img_label.pack()
    except tk.TclError:
        print("Error loading image.")
else:
    print("Image file not found.")

# Create labels and entry widgets for parameters
tk.Label(window, text="Karaoke Name:", font=("Arial", 14)).pack(anchor="w")
karaoke_name_entry = tk.Entry(window, font=("Arial", 12))
karaoke_name_entry.pack(anchor="w", padx=10)

tk.Label(window, text="Video URL:", font=("Arial", 14)).pack(anchor="w")
video_url_entry = tk.Entry(window, font=("Arial", 12))
video_url_entry.pack(anchor="w", padx=10)

# Create a button to execute the shell script
submit_button = tk.Button(window, text="Submit", command=run_shell_script, font=("Arial", 12))
submit_button.pack(pady=10)

# Create a button to terminate shell script
submit_button = tk.Button(window, text="KILL", command=Terminator, font=("Arial", 15))
submit_button.pack(pady=13)

# Start the main event loop
window.mainloop()
