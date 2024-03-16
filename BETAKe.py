import os
import tkinter as tk
from tkinter import messagebox
import subprocess

def run_shell_script():
    karaoke_name = karaoke_name_entry.get()
    video_url = video_url_entry.get()

    # Call the shell script with parameters
    script_command = ["sh", "betaREC.sh", karaoke_name, video_url]
    try:
        subprocess.run(script_command, check=True)
        messagebox.showinfo("Success", "Shell script executed successfully.")
    except subprocess.CalledProcessError:
        messagebox.showerror("Error", "Failed to execute shell script.")
    except Exception as e:
        messagebox.showerror("Error", f"An error occurred: {str(e)}")
    finally:
        # Close the Tkinter window
        window.destroy()
def Terminator():
    window.destroy()
    exit()

# Create the main window
window = tk.Tk()
window.title("Karaoke Shell Interface")

# Set window size and position
window.geometry("400x1200")
window.resizable(False, False)

# Customize the theme
window.configure(bg="#BABACA")
tk.Label(window, text="BETAKe Karaoke Shell Interface", bg="#f0f0f0", font=("Arial", 16)).pack(pady=10)

# Create labels and entry widgets for parameters
tk.Label(window, text="Karaoke Name:", bg="#f0f0f0", font=("Arial", 12)).pack(anchor="w")
karaoke_name_entry = tk.Entry(window, font=("Arial", 12))
karaoke_name_entry.pack(pady=5)

tk.Label(window, text="Video URL:", bg="#f0f0f0", font=("Arial", 12)).pack(anchor="w")
video_url_entry = tk.Entry(window, font=("Arial", 12))
video_url_entry.pack(pady=5)

# Create a button to execute the shell script
submit_button = tk.Button(window, text="Submit", command=run_shell_script, font=("Arial", 12))
submit_button.pack(pady=10)

# Create a button to terminate shell script
submit_button = tk.Button(window, text="KILL", command=Terminator, font=("Arial", 15))
submit_button.pack(pady=13)

# Add image
image_path = os.path.join(os.path.dirname(__file__), "tux.jpeg")
if os.path.exists(image_path):
    try:
        img = tk.PhotoImage(file=image_path)
        img_label = tk.Label(window, image=img, bg="#f0f0f0")
        img_label.pack()
    except tk.TclError:
        print("Error loading image.")
else:
    print("Image file not found.")

# Start the main event loop
window.mainloop()
