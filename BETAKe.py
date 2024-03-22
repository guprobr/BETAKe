#!/usr/bin/env python3

import threading 
import tkinter as tk
from tkinter import scrolledtext
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
        master.title("BETAKe Karaoke Shell Interface")
        master.geometry("1024x840")  # Set window size
        
        # Create scrolled text widget for displaying output
        self.output_text = scrolledtext.ScrolledText(master, wrap=tk.WORD, background="black", foreground="gray")
        self.output_text.place(x=0, y=0, width=1024, height=510)

        # Create a button to scroll to the end of the text widget
        self.scroll_to_end_button = tk.Button(master, text="Scroll to End", command=self.scroll_to_end)
        self.scroll_to_end_button.place(x=550, y=740, width=150, height=30)  

        # Load and display the left-aligned tux.png image
        self.left_image = tk.PhotoImage(file=betake_path + "/tux.png")
        self.left_image_label = tk.Label(master, image=self.left_image)
        self.left_image_label.place(x=10, y=500)

        # Load and display the right-aligned tux.png image
        self.right_image = tk.PhotoImage(file=betake_path + "/tux.png")
        self.right_image_label = tk.Label(master, image=self.right_image)
        self.right_image_label.place(x=800, y=500)

        # Entry for custom karaoke name
        tk.Label(master, text="Karaoke Name:").place(x=250, y=530)
        self.karaoke_name_entry = tk.Entry(master)
        self.karaoke_name_entry.place(x=350, y=530, width=440)

        # Entry for custom video URL
        tk.Label(master, text="Video URL:").place(x=250, y=570)
        self.video_url_entry = tk.Entry(master)
        self.video_url_entry.place(x=350, y=570, width=440)

        # Start recording button
        self.start_recording_button = tk.Button(
            master, text="Start Recording", command=self.start_recording)
        self.start_recording_button.place(x=10, y=690, width=300, height=66)

        # Kill recording button
        self.kill_button = tk.Button(
            master, text="Kill BETAKê", command=self.kill_recording)
        self.kill_button.place(x=790, y=690, width=300, height=66)
        # Button to fetch random karaoke video URL
        self.random_karaoke_button = tk.Button(
            master, text="Feel Lucky", command=self.fetch_random_karaoke_url)
        self.random_karaoke_button.place(x=350, y=620, width=100)
        # Get fortune button
        self.fortune_button = tk.Button(
            master, text="Get Fortune", command=self.get_fortune)
        self.fortune_button.place(x=450, y=620, width=100)

        #Display fortunes at the beginning
        self.display_fortunes()
        # Start updating the sound meter
        #self.update_sound_meter()

    def update_sound_meter(self):
        try:
            # Read audio data from the stream
            audio_data = np.frombuffer(self.stream.read(self.chunk_size), dtype=np.int16)
            # Calculate the sound level (RMS value)
            rms = np.sqrt(np.mean(np.square(audio_data)))
            # Check for NaN value
            if np.isnan(rms):
                print("Error: NaN value detected in RMS calculation")
                # Stop updating the sound meter
                return
            # Normalize the sound level to a value between 0 and 100
            sound_level = int(100 * rms / 32768)
            # Update the progress bar with the sound level
            self.sound_meter['value'] = sound_level
        except Exception as e:
            print("Error:", e)
        # Schedule the next update
        self.master.after(100, self.update_sound_meter)


    # Function to process audio data
    def process_audio(data):
        # Convert audio data to numpy array
        audio_array = np.frombuffer(data, dtype=np.int16)

        # Example: Calculate RMS (Root Mean Square) amplitude
        rms = np.sqrt(np.mean(np.square(audio_array)))

        # Example: Print RMS value
        print("RMS Amplitude:", rms)

    def scroll_to_end(self):
        self.output_text.see(tk.END)

        # Define a dictionary to map color codes to hexadecimal color values
        self.color_map = {
            '90': '♪',  # Music note
            '91': '☹',  # Frowning face
            '92': '☺',  # Smiling face
            '93': '♥',  # Heart
            '94': '♦',  # Diamond
            '95': '♪',  # Eighth note (just repeating for variety)
            '96': '☻',  # Black smiling face
            '97': '☼',   # Sun
        }
        # Configure tags for different colors
        for color_code, color_hex in self.color_map.items():
            self.output_text.tag_config(f"color_{color_code}", foreground='#' + color_code + '0000')

    def colorize_and_display(self, line):
        # Replace color escape sequences with corresponding tags
        for color_code, color_hex in self.color_map.items():
            line = re.sub(r'\[' + color_code + r'm', f'{color_hex}>', line)
        line = re.sub(r'\[0m', "<<", line)  # Reset to default color
        
        # Insert colorized text into the text widget
        self.output_text.insert(tk.END, line + '\n')
        self.scroll_to_end()

    def start_tailf(self):
        logfile = betake_path + "/script.log"
        command = ['tail', '-f', logfile]
        process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

        while True:
            line = process.stdout.readline().decode('utf-8').rstrip()
            if line:
                self.colorize_and_display(line)


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
            "https://music.youtube.com/watch?v=ksk74Itay8E",
            "https://music.youtube.com/watch?v=9BCQqo1XMVw",
            "https://music.youtube.com/watch?v=WYNgRNCi6ZE",
            "https://music.youtube.com/watch?v=3BDn16q_pvM",
            "https://music.youtube.com/watch?v=vkl-GXuQRF8",
            "https://music.youtube.com/watch?v=s--ChSEsjKk",
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
            "https://music.youtube.com/watch?v=3WLy3Ablvm",
            "https://music.youtube.com/watch?v=IM8pV2wedpc",
            "https://music.youtube.com/watch?v=m8CEEkqQiiY",
            "https://music.youtube.com/watch?v=FKGwe5tf_H4",
            "https://music.youtube.com/watch?v=EVNFbhrJC-o",
            "https://music.youtube.com/watch?v=5zGdD6CGPhs",
            "https://music.youtube.com/watch?v=9pnmzgzx8Y",
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
            "https://music.youtube.com/watch?v=UVDyFA0HYPw",
            "https://music.youtube.com/watch?v=cMXGjNsXNAw",
            "https://music.youtube.com/watch?v=dh0gLJCvmcI",
            "https://music.youtube.com/watch?v=Z6Zr01BfjBM",
            "https://music.youtube.com/watch?v=zk_jFyM7MtM",
            "https://music.youtube.com/watch?v=byhOlv1UvBQ",
            "https://music.youtube.com/watch?v=d_sQIBh01GQ"
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
            
            #First, truncate last log
            command = [ 'truncate', '-s0', f'{betake_path}/script.log'  ]
            # Launch truncation of script.log
            subprocess.Popen(command)
            # Command to execute betaREC.sh with tee for logging
            command = [
                'bash', '-c',
                f'{betake_path}/gammaQ.sh {karaoke_name} {video_url} {betake_path} 2>&1 | tee -a script.log'
            ]

            # Launch betaREC.sh inside xterm and redirect output to script.log
            subprocess.Popen(command)
            #feed with the log our nice window
            self.start_tailf()

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
        command = [ 'wmctrl', '-c', '"BETAKê CMD prompt"' ]
            # Launch truncation of script.log
        subprocess.Popen(command)
        # Quit the interface, try housekeeping
        self.master.quit()
      

def main():
    root = tk.Tk()
    app = App(root)
    root.mainloop()

if __name__ == "__main__":
    main()
     
   
