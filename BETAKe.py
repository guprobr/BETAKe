#!/usr/bin/env python3
import threading 
import tkinter as tk
from tkinter import scrolledtext
from tkinter.font import Font
from tkinter.ttk import Progressbar
import subprocess
import re
import pyaudio
import numpy as np



betake_path = "./"  # DEFAULT: BETAKE_PATH
logfile = "script.log"  # Path to the log file

class App:
    def __init__(self, master):
        self.master = master
        master.title("gammaQ v3")
        master.geometry("1024x777")  # Set window size

        # Define instance variables for buttons
        self.test_video_button = None
        self.audio_loopback_button = None
        
        custom_font = Font(family="Terminus", size=12, weight="bold")
        # Create scrolled text widget for displaying output
        self.output_text = scrolledtext.ScrolledText(master, wrap=tk.WORD, background="black", foreground="gray", font=custom_font)
        self.output_text.place(x=0, y=0, width=1024, height=510)

        # Load and display the left-aligned tux.png image
        self.left_image = tk.PhotoImage(file=betake_path + "/tux.png")
        self.left_image_label = tk.Label(master, image=self.left_image)
        self.left_image_label.place(x=400, y=580) 

        # Entry for custom karaoke name
        tk.Label(master, text="Karaoke OUTPUT Name:").place(x=1, y=530)
        self.karaoke_name_entry = tk.Entry(master)
        self.karaoke_name_entry.place(x=160, y=530, width=750)

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
            master, text="Kill BETAKê", command=self.kill_recording)
        self.kill_button.place(x=730, y=600, width=300, height=166)

        
        #First, truncate last log
        command = [ 'truncate', '-s0', f'{betake_path}/script.log'  ]
        # Launch truncation of script.log
        subprocess.Popen(command)
        #Display fortunes at the beginning
        self.display_fortunes()
        # Start tailf in a separate thread
        threading.Thread(target=self.start_tailf, daemon=True).start()


    def scroll_to_end(self):
        self.output_text.see(tk.END)

     
    def start_tailf(self):
        logfile = betake_path + "/script.log"
        command = ['tail', '-f', logfile]
        process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

        while True:
            line = process.stdout.readline().decode('utf-8').rstrip()
            if line:
                self.colorize_line(line)
                self.output_text.insert(tk.END, line + '\n')
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
                self.output_text.tag_add(tag_name, 'end - %dc' % len(line_without_escapes), 'end')

        # Scroll to the end of the widget
        self.scroll_to_end()

        # Reset to default foreground color after termination escape code (39)
        if '0' in escape_codes:
            default_color = '#FFFFFF'  # White color
            self.output_text.tag_config('default_color', foreground=default_color)
            self.output_text.insert(tk.END, line_without_escapes + '\n', 'default_color')
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
        # List of YouTube URLs
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
            "https://www.youtube.com/watch?v=avnVW9frwLE"
        ]

        fortune_char_count = len(self.get_random_fortune())

        # Calculate default video index using modulus
        default_video_index = fortune_char_count % len(youtube_urls)

        # Set default video URL
        default_video_url = youtube_urls[default_video_index]

        return default_video_url

    def start_recording(self):
        # Define a function to be executed in a separate thread
        def start_recording_thread():
            # Get karaoke name and video URL from entry widgets
            self.start_recording_button.config(state=tk.DISABLED)

            karaoke_name = "BETAKE"
            karaoke_name = self.karaoke_name_entry.get().strip()
            video_url = self.video_url_entry.get().strip()

            # Set default values if input fields are empty
            if not karaoke_name:
                karaoke_name = "BETAKE"
            if not video_url:
                default_video_url = self.get_default_video_url()
                video_url = default_video_url
            
            # Command to execute betaREC.sh with tee for logging
            command = [
                'bash', '-c',
                f'{betake_path}/gammaQ.sh {karaoke_name} {video_url} {betake_path} 2>&1 | tee -a script.log'
            ]

            # Launch betaREC.sh inside xterm and redirect output to script.log
            subprocess.Popen(command)
             # Poll the process until it finishes
            while self.process.poll() is None:
                # Optionally, you can add a delay to reduce CPU usage
                self.time.sleep(1)

            
            print("Recording thread has ended")
            self.start_recording_button.config(state=tk.NORMAL)

        # Create a new thread and start it
        recording_thread = threading.Thread(target=start_recording_thread)
        recording_thread.start()  
    
    def kill_parent_and_children(pself, parent_process_name):
        try:
            # Find the PID of the parent process
            parent_pid = subprocess.check_output(["pgrep", parent_process_name]).strip().decode()

            # Find and terminate all children processes
            subprocess.run(["killall", "-TERM", "-P", parent_pid])
        except subprocess.CalledProcessError:
            print("Error: Failed to find or terminate parent process and its children.")

    def kill_recording(self):     
        # Quit the interface, try housekeeping
        self.kill_parent_and_children("gammaQ.sh")
        self.master.quit()

def main():
    root = tk.Tk()
    app = App(root)
    root.mainloop()

if __name__ == "__main__":
    main()
     
   
