#!/usr/bin/env python3

betake_path = "./"  # DEFAULT: BETAKE_PATH

import time
import threading
import subprocess
import os
import re
import psutil

import tkinter as tk
import tkinter.messagebox
from tkinter import ttk
from tkinter import scrolledtext
from tkinter.font import Font
import tkinter.filedialog
import webbrowser
import numpy as np

logfile = f'{betake_path}/script.log'  # Path to the log file
os.chdir(betake_path)
class DeviceSelectionDialog:
    
    def __init__(self, parent, devices):
        self.parent = parent
        self.devices = devices
        self.selected_device = None
        

        self.dialog = tk.Toplevel(parent)
        self.dialog.title("Select Video Device")
        self.dialog.geometry("200x300")

        self.device_listbox = tk.Listbox(self.dialog)
        for device in devices:
            self.device_listbox.insert(tk.END, device)
        self.device_listbox.pack(expand=True, fill=tk.BOTH)

        self.select_button = ttk.Button(self.dialog, text="Select", command=self.select_device)
        self.select_button.pack(pady=5)
    
    def select_device(self):
        selected_index = self.device_listbox.curselection()
        if selected_index:
            self.selected_device = self.devices[selected_index[0]]
            self.dialog.destroy()
#########################################################
def list_video_devices():
    devices = []
    try:
        output = subprocess.check_output(['v4l2-ctl', '--list-devices'], text=True)
        lines = output.strip().split('\n')
        for line in lines:
            if line.strip().startswith('/dev/video'):
                devices.append(line.strip())
    except subprocess.CalledProcessError:
        print("Error: Failed to list video devices using v4l2-ctl.")
        App.output_text.insert(tk.END, "Error: Failed to list video devices using v4l2-ctl." + '\n')
        App.kill_recording()
    return devices

def open_device_selection_dialog(parent):
    devices = list_video_devices()
    if not devices:
        print("No video devices found.")
        parent.output_text.insert(tk.END, "No video devices found." + '\n')
        App.kill_recording()
        return

    dialog = DeviceSelectionDialog(parent, devices)
    parent.wait_window(dialog.dialog)
    return dialog.selected_device

class App:
    
    def __init__(self, master):
        self.master = master
        master.title("gammaQ v3")
        master.geometry("1024x777")  # Set window size

        # Define instance variables for buttons
        self.test_video_button = None
        self.audio_loopback_button = None
        self.video_dev_dialog_open = False
        self.tail_log_open = None

        custom_font = Font(family="Terminus", size=12, weight="bold")
        # Create scrolled text widget for displaying output
        self.output_text = scrolledtext.ScrolledText(master, wrap=tk.WORD, background="black", foreground="gray", font=custom_font)
        self.output_text.place(x=0, y=0, width=1024, height=510)

        # Load and display the left-aligned tux.png image
        self.left_image = tk.PhotoImage(file=betake_path + "/tux.png")
        self.left_image_label = tk.Label(master, image=self.left_image)
        self.left_image_label.place(x=400, y=580) 

        self.select_video_device_button = tk.Button(
            master, text="cfg /dev/video", command=self.select_video_device)
        self.select_video_device_button.place(x=295, y=595)
        
        self.video_dev_entry = tk.Entry(master)
        self.video_dev_entry.place(x=300, y=635, width=100)
        self.video_dev_entry.insert(0, "/dev/video0")

        self.get_fortune_button = tk.Button(
            master, text="yer Fortunes", command=self.get_fortune)
        self.get_fortune_button.place(x=600, y=595)

        self.select_mp4_button = tk.Button(
            master, text="Select MP4", command=self.select_mp4_file)
        self.select_mp4_button.place(x=600, y=700)

        self.tail_log_button = tk.Button(
            master, text="Tail Logs", command=self.tail_log)
        self.tail_log_button.place(x=600, y=640)

        # Entry for custom karaoke name
        tk.Label(master, text="Karaoke OUTPUT Name:").place(x=1, y=530)
        self.karaoke_name_entry = tk.Entry(master)
        self.karaoke_name_entry.place(x=160, y=530, width=750)
        self.karaoke_name_entry.bind('<KeyRelease>', self.sanitize_input)


        # Entry for custom video URL
        tk.Label(master, text="Playback Video URL:").place(x=1, y=570)
        self.video_url_entry = tk.Entry(master)
        self.video_url_entry.place(x=160, y=570, width=750)

        # Start recording button
        self.start_recording_button = tk.Button(
            master, text="Start Recording", command=self.start_recording)
        self.start_recording_button.place(x=10, y=600, width=280, height=166)

        # Kill recording button
        self.kill_button = tk.Button(
            master, text="KaraoKe KiLL", command=self.kill_recording)
        self.kill_button.place(x=730, y=600, width=300, height=166)

        
        #First, truncate last log
        command = [ 'truncate', '-s0', f'{betake_path}/script.log'  ]
        # Launch truncation of script.log
        subprocess.Popen(command)
        #Display fortunes at the beginning
        self.display_fortunes()
        # Start tailf in a separate thread
        threading.Thread(target=self.start_tailf, daemon=True).start()

    def select_video_device(self):
        if not self.video_dev_dialog_open:
            self.video_dev_dialog_open = True
            selected_devCam = open_device_selection_dialog(self.master)
            self.video_dev_dialog_open = False
            if selected_devCam:
                print(f"Selected video device: {selected_devCam}")
                self.output_text.insert(tk.END, f"Selected video device: {selected_devCam} " + '\n')
                self.video_dev_entry.delete(0, tk.END)
                self.video_dev_entry.insert(0, selected_devCam)

    def scroll_to_end(self):
        self.output_text.see(tk.END)

    def sanitize_input(self, event):
        # Get the current text from the entry widget
        current_text = self.karaoke_name_entry.get()
        
        # Define a list of characters to be replaced
        invalid_chars = [' ', '"', "'", ',', '.', '!', '@', '#', '$', '%', '^', '&', '*', '(', ')', '_', '-', '=', '+', '\\', '/', '[', ']', '{', '}', '|', '<', '>', '?']
        
        # Replace invalid characters with underscores
        sanitized_text = ''.join(['_' if char in invalid_chars else char for char in current_text])
        
        # Update the entry widget with the sanitized text
        self.karaoke_name_entry.delete(0, tk.END)
        self.karaoke_name_entry.insert(0, sanitized_text)
     
    def start_tailf(self):
        logfile = betake_path + "/script.log"
        command = ['tail', '-f', logfile]
        process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

        while True:
            line = process.stdout.readline().decode('utf-8').rstrip()
            #if line and ('🎵' in line or '𝄞' in line):
            self.colorize_line(line)
            self.scroll_to_end()

    def colorize_line(self, line):
        # Define a regular expression to match escape codes for foreground colors
        escape_code_pattern = re.compile(r'\033\[(\d{1,2})m')

        # Remove escape codes from the line
        line_without_escapes = escape_code_pattern.sub('', line)

        # Find all escape codes in the line
        escape_codes = escape_code_pattern.findall(line)

        # Define a mapping of escape codes to tag names and corresponding colors
        tag_color_map = {
            '30': ('color_0', '#000000'),  # Black
            '31': ('color_1', '#FF0000'),  # Red
            '32': ('color_2', '#00FF00'),  # Green
            '33': ('color_3', '#FFFF00'),  # Yellow
            '34': ('color_4', '#0000FF'),  # Blue
            '35': ('color_5', '#FF00FF'),  # Magenta
            '36': ('color_6', '#00FFFF'),  # Cyan
            '37': ('color_7', '#FFFFFF')   # White
        }

        # Apply tags to the entire line
        for escape_code in escape_codes:
            if escape_code in tag_color_map:
                tag_name, hex_color = tag_color_map[escape_code]
                if tag_name not in self.output_text.tag_names():
                    self.output_text.tag_config(tag_name, foreground=hex_color)

        # Insert the line without escape codes into the widget and apply tags
        self.output_text.insert(tk.END, line_without_escapes + '\n')
        for escape_code in escape_codes:
            if escape_code in tag_color_map:
                tag_name, _ = tag_color_map[escape_code]
                self.output_text.tag_add(tag_name, 'end - %dc' % (len(line_without_escapes) + 2), 'end')

        

        # Reset to default foreground color after termination escape code (39)
        if '0' in escape_codes:
            default_color = '#FFAA0E'  # White color
            self.output_text.tag_config('default_color', foreground=default_color)
            self.output_text.insert(tk.END, "🎵", 'default_color')


        # Scroll to the end of the widget
        self.scroll_to_end()



    def fetch_random_karaoke_url(self):
   # Command to fetch random karaoke video URL
        command = [
            'yt-dlp', 'ytsearch:"karaoke lyrics"', '--match-filter', 'duration < 300', '--no-playlist', '--simulate',
        ]

        try:
            # Execute the command and capture the output
            output = subprocess.check_output(command, text=True).strip()
            self.output_text.insert(tk.END, output + "\n")
            self.scroll_to_end()

            # Define a regular expression pattern to match the URL
            url_pattern = r'\[youtube\] Extracting URL: (.+)$'

            # Search for the URL pattern in each line of the output
            for line in output.split('\n'):
                match = re.search(url_pattern, line)
                if match:
                    url = match.group(1)
                    print("Found URL:", url)
                    self.output_text.insert(tk.END, "Found URL:" + url + "\n")
                    self.scroll_to_end()

                    # Set the output as the value of the second input text field
                    self.video_url_entry.delete(0, tk.END)
                    self.video_url_entry.insert(0, url)
                    break

        except subprocess.CalledProcessError:
            print("Error: Failed to fetch karaoke video URL.")
            self.output_text.insert(tk.END, "Error: Failed to fetch karaoke video URL." + '\n')


    def display_fortunes(self):
        # Get and display three random fortunes
        for _ in range(3):
            fortune = self.get_random_fortune()

            self.output_text.insert(tk.END, fortune + "\n")
        self.scroll_to_end()

    def get_random_fortune(self):
        # Get a random fortune using the fortune command
        try:
            fortune = subprocess.check_output(["fortune"]).decode().strip()
        except subprocess.CalledProcessError:
            fortune = "Failed to retrieve fortune. Please install fortunes manually."
        return fortune
    
    def get_fortune(self):
        fortune = self.get_random_fortune()
        self.output_text.insert(tk.END, fortune + "\n", "important")
        self.scroll_to_end()

    def get_default_video_url(self):
        # List of YouTube URLs when user does not fill URL text input
        youtube_urls = [
            "https://music.youtube.com/watch?v=eby0bVEIWcs",
            "https://music.youtube.com/watch?v=s8kcyeTd2OQ",
            "https://music.youtube.com/watch?v=t2iIEETOtGk",
            "https://music.youtube.com/watch?v=9BCQqo1XMVw",
            "https://music.youtube.com/watch?v=WYNgRNCi6ZE",
            "https://music.youtube.com/watch?v=3BDn16q_pvM",
            "https://music.youtube.com/watch?v=vkl-GXuQRF8",
            "https://music.youtube.com/watch?v=gCrqBZlxSyA",
            "https://music.youtube.com/watch?v=y_IIuMX0rHA",
            "https://music.youtube.com/watch?v=FyNo7zGZ720",
            "https://music.youtube.com/watch?v=Adb4fbt4Y0g",
            "https://music.youtube.com/watch?v=80WiXlN-Erk",
            "https://music.youtube.com/watch?v=XsVWMM2CO0U",
            "https://music.youtube.com/watch?v=OBzl83j-8IE",
            "https://music.youtube.com/watch?v=LA6VwQ0HXdE",
            "https://music.youtube.com/watch?v=6CYj5wxOkes",
            "https://music.youtube.com/watch?v=S5_4MjmQ5YA",
            "https://music.youtube.com/watch?v=9pe4JSIhXg0",
            "https://music.youtube.com/watch?v=oLggPLDvCoc",
            "https://music.youtube.com/watch?v=1R2abdk_JJk",
            "https://music.youtube.com/watch?v=08SGDHJ2fLY",
            "https://music.youtube.com/watch?v=IM8pV2wedpc",
            "https://music.youtube.com/watch?v=m8CEEkqQiiY",
            "https://music.youtube.com/watch?v=FKGwe5tf_H4",
            "https://music.youtube.com/watch?v=EVNFbhrJC-o",
            "https://music.youtube.com/watch?v=5zGdD6CGPhs",
            "https://music.youtube.com/watch?v=JtiocB8PYPs",
            "https://music.youtube.com/watch?v=o59aaEyoe_4",
            "https://music.youtube.com/watch?v=ANbCnAwBw1U",
            "https://music.youtube.com/watch?v=nDNGjZfCGOU",
            "https://music.youtube.com/watch?v=HTXiC8g3F40",
            "https://music.youtube.com/watch?v=UmfyX7v99Ug",
            "https://music.youtube.com/watch?v=u-_Nlaf6g2I",
            "https://music.youtube.com/watch?v=OU3699R53rs",
            "https://music.youtube.com/watch?v=w-ica9spTNg",
            "https://music.youtube.com/watch?v=aDFZHLYFb7s",
            "https://music.youtube.com/watch?v=OBIHNRtZeW8",
            "https://music.youtube.com/watch?v=8R7ies_GPAE",
            "https://music.youtube.com/watch?v=uzHT-qq6qi4",
            "https://music.youtube.com/watch?v=p7qA45Bh8-Q",
            "https://music.youtube.com/watch?v=uj4-_JL7-Tk",
            "https://music.youtube.com/watch?v=cMXGjNsXNAw",
            "https://music.youtube.com/watch?v=dh0gLJCvmcI",
            "https://music.youtube.com/watch?v=Z6Zr01BfjBM",
            "https://music.youtube.com/watch?v=zk_jFyM7MtM",
            "https://music.youtube.com/watch?v=byhOlv1UvBQ",
            "https://music.youtube.com/watch?v=d_sQIBh01GQ",
            "https://music.youtube.com/watch?v=ccmfH8Pjtk4",
            "https://music.youtube.com/watch?v=aZW1c3XlDwA",
            "https://music.youtube.com/watch?v=wxJ4meJkt7A",
            "https://music.youtube.com/watch?v=l27xaGlvV_0",
            "https://music.youtube.com/watch?v=z4oxh0ZZX8M",
            "https://music.youtube.com/watch?v=GMexo55tieg",
            "https://music.youtube.com/watch?v=h-C7U3EVNEE",
            "https://music.youtube.com/watch?v=3M8IPpeIwVc",
            "https://music.youtube.com/watch?v=Z1MLaexgBtc",
            "https://music.youtube.com/watch?v=zWO5BOalVpQ",
            "https://music.youtube.com/watch?v=8GQwtYd0tfw",
            "https://music.youtube.com/watch?v=X0COGw91wzk",
            "https://music.youtube.com/watch?v=UPFCB1Lzawo",
            "https://music.youtube.com/watch?v=X0jcTY5lp0M",
            "https://music.youtube.com/watch?v=mby-A4lz1-s",
            "https://music.youtube.com/watch?v=CZl1ZSr9yb4",
            "https://music.youtube.com/watch?v=5Y60rPLUNJQ",
            "https://music.youtube.com/watch?v=9w3eg4lVjv4",
            "https://music.youtube.com/watch?v=dPtDT4lI0P0",
            "https://music.youtube.com/watch?v=jx7WliEB5_A",
            "https://music.youtube.com/watch?v=xgNfHIfcUi0",
            "https://music.youtube.com/watch?v=QDD_zhqG7VI",
            "https://music.youtube.com/watch?v=2ST6RIplEJg",
            "https://www.youtube.com/watch?v=avnVW9frwLE",
            "https://music.youtube.com/watch?v=3yCecD_23tA"
        ]

        fortune_char_count = len(self.get_random_fortune())

        # Calculate default video index using modulus
        default_video_index = fortune_char_count % len(youtube_urls)

        # Set default video URL
        default_video_url = youtube_urls[default_video_index]

        return default_video_url
    
    def select_mp4_file(self):
        # Open a file dialog to select an MP4 file
        mp4_file = tkinter.filedialog.askopenfilename(
            initialdir=betake_path + "/recordings/",
            title="Select an MP4 file",
            filetypes=(("MP4 files", "*.mp4"), ("All files", "*.*"))
        )

        if mp4_file:
            # Open the selected MP4 file with the default web browser
            webbrowser.open(f"file://{mp4_file}")
            self.video_url_entry.insert(0, f"file://{mp4_file}")
            # Show a dialog asking a yes/no question
        response = tkinter.messagebox.showinfo(
            "Preview cached playback", "Click start to record this choice, or choose another cached playback/external URL"
        )

    def start_recording(self):
        # Get karaoke filename and video URL from entry widgets
        self.start_recording_button.config(state=tk.DISABLED)

        karaoke_name = self.karaoke_name_entry.get().strip()
        video_dev = self.video_dev_entry.get().strip()
        video_url = self.video_url_entry.get().strip()

        # Set default values if input fields are empty
        if not karaoke_name:
            karaoke_name = "BETAKE"
        if not video_url:
            default_video_url = self.get_default_video_url()
            video_url = default_video_url
        if not video_dev:
            video_dev = "/dev/video0"
        
        # Command to execute betaREC.sh with tee for logging
        command = [
            'bash', '-c',
            f'{betake_path}/gammaQ.sh "{karaoke_name}" "{video_url}" "{betake_path}" "{video_dev}" 2>&1 | tee -a script.log'
        ]

        # Launch gammaQ.sh and redirect output to script.log
        self.subprocess = subprocess.Popen(command, shell=False, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

        # Define a function to check the subprocess status
        def check_subprocess_status():
            while True:
                if self.subprocess.poll() is not None:
                    break
                time.sleep(1)

            # Enable the button when the subprocess finishes
            self.master.after(0, lambda: self.start_recording_button.config(state=tk.NORMAL))

        # Start a separate thread to check the subprocess status
        threading.Thread(target=check_subprocess_status).start()
    
    def tail_log(self):
        def check_tail_log_subprocess_status():
            self.subprocess.wait()  # Wait for the subprocess to finish
            # Enable the button when the subprocess finishes
            self.tail_log_button.config(state=tk.NORMAL)
            self.tail_log_open = False

        if not self.tail_log_open:
            self.tail_log_open = True
            self.tail_log_button.config(state=tk.DISABLED)
             # Command to housekeep tailing -f script.log
            command = [ 'wmctrl', '-c', 'Tail_Logs' ]
            self.subprocess = subprocess.Popen(command, shell=False, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

            # Command to execute gnome-terminal tailing -f script.log
            command = [ 'gnome-terminal', '-t', 'Tail_Logs', '--',
                'tail', '-f', f'{betake_path}/script.log'
            ]
            self.subprocess = subprocess.Popen(command, shell=False, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

            # Start a separate thread to check the subprocess status
            threading.Thread(target=check_tail_log_subprocess_status).start()

    def cleanup(self):
        if self.subprocess is not None:
            self.subprocess.terminate()  # Terminate the subprocess

    
    def kill_children(self, parent_process_name):
        parent_pid = os.getpid()  # Get PID of the parent process (Tkinter window)
        parent = psutil.Process(parent_pid)

        # Iterate through all child processes
        for child in parent.children(recursive=True):
            child.terminate()  # Terminate child process

    def kill_recording(self):     
        # Quit the interface, try housekeeping
        self.master.quit()
        self.kill_children("BETAKe.py")
         # Command to execute py script tailing -f script.log
        command = [ 'pactl', 
                   'unload-module', 'module-loopback'
        ]
        # Create subprocess with shell=True
        self.subprocess = subprocess.Popen(command, shell=False)

def main():
    root = tk.Tk()
    app = App(root)

    root.mainloop()

if __name__ == "__main__":
    main()
     
   
