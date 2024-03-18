#!/usr/bin/python3

import tkinter as tk
from tkinter import scrolledtext
import subprocess

betake_path = "./" # DEFAULT: BETAKE_PATH

class App:
    def __init__(self, master):
        self.master = master
        master.title("BETAKe Karaoke Shell Interface")
        master.geometry("800x600")  # Set window size
        # Example usage
        

        # Load and display the left-aligned tux.png image
        self.left_image = tk.PhotoImage(file=betake_path + "/tux.png")
        self.left_image_label = tk.Label(master, image=self.left_image)
        self.left_image_label.place(x=10, y=230)

        # Load and display the right-aligned tux.png image
        self.right_image = tk.PhotoImage(file=betake_path + "/tux.png")
        self.right_image_label = tk.Label(master, image=self.right_image)
        self.right_image_label.place(x=630-self.right_image.width(), y=230)

        # Create scrolled text widget for displaying output
        self.output_text = scrolledtext.ScrolledText(master, wrap=tk.WORD, background="black", foreground="gray")
        self.output_text.place(x=10, y=10, width=620, height=200)

        # Entry for custom karaoke name
        tk.Label(master, text="Karaoke Name:").place(x=150, y=230)
        self.karaoke_name_entry = tk.Entry(master)
        self.karaoke_name_entry.place(x=250, y=230, width=200)

        # Entry for custom video URL
        tk.Label(master, text="Video URL:").place(x=150, y=270)
        self.video_url_entry = tk.Entry(master)
        self.video_url_entry.place(x=250, y=270, width=200)

        # Start recording button
        self.start_recording_button = tk.Button(master, text="Start Recording", command=self.start_recording)
        self.start_recording_button.place(x=250, y=320, width=100)

        # Kill recording button
        self.kill_button = tk.Button(master, text="Kill Recording", command=self.kill_recording)
        self.kill_button.place(x=350, y=320, width=100)

        # Display fortunes at the beginning
        self.display_fortunes()

    def display_fortunes(self):
        # Get and display three random fortunes
        for _ in range(3):
            fortune = self.get_random_fortune()
            self.output_text.insert(tk.END, fortune + "\n")
        self.output_text.see(tk.END)

    def get_random_fortune(self):
        # Get a random fortune using the fortune command
        try:
            fortune = subprocess.check_output(["fortune"]).decode().strip()
        except subprocess.CalledProcessError:
            fortune = "Failed to retrieve fortune. Please install fortunes manually."
        return fortune
    
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
            "https://music.youtube.com/watch?v=w-ica9spTNg"
        ]
        
        ##today_fortune = self.get_random_fortune()
        fortune_char_count = len(self.get_random_fortune())
        
        # Calculate default video index using modulus
        default_video_index = fortune_char_count % len(youtube_urls)
        
        # Set default video URL
        default_video_url = youtube_urls[default_video_index]
        
        return default_video_url

    def start_recording(self):
        # Get karaoke name and video URL from entry widgets
        karaoke_name = self.karaoke_name_entry.get().strip()
        video_url = self.video_url_entry.get().strip()
    
        # Set default values if input fields are empty
        if not karaoke_name:
            karaoke_name = "BETAKE"
        if not video_url:
            default_video_url = self.get_default_video_url()
            video_url = default_video_url
        # Launch betaREC.sh inside xterm
        subprocess.Popen([betake_path + '/' + 'betaREC.sh', karaoke_name, video_url, betake_path])

    def kill_recording(self):
        # Quit the interface, try housekeeping
        subprocess.Popen(['killall', '-HUP', 'pipewire-pulse'])
        self.master.quit()



def main():
    root = tk.Tk()
    app = App(root)
    root.mainloop()

if __name__ == "__main__":
    main()