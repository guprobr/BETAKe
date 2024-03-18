#!/usr/bin/python3

import tkinter as tk
from tkinter import scrolledtext
import subprocess
import os
import signal
import time
        
betake_path = "./" # DEFAULT: BETAKE_PATH
def betaREC(karaoke_name, video_url, betake_path):
        input_dir = betake_path # Assuming input directory is the current directory
        file_name = karaoke_name

        # Change directory
        os.chdir(input_dir)
        colored_print(os.getcwd(), "yellow")

        # Launch pavumeter and pavucontrol
        run_command("pavumeter &")
        run_command("pavucontrol &")

        # Unload existing PulseAudio modules
        colored_print("Unload existing modules and restart PulseAudio", "yellow")
        run_command("pactl unload-module module-ladspa-sink")
        run_command("pactl unload-module module-loopback")
        run_command("pactl unload-module module-echo-cancel")
        run_command("killall -HUP pipewire-pulse")

        # Load configuration variables
        SINKA = "beta_loopy"
        SINKB = "beta_kombo"
        SINKC = "beta_recz"

    # Housekeeping sound servers
        colored_print("*HOUSEKEEPING SOUND SERVERS*", "yellow")
        run_command(f"nautilus {os.path.join(input_dir, 'playz')} &")
        run_command(f"nautilus {os.path.join(input_dir, 'recz')} &")

    # Initialize microphone sink
        colored_print("INIT MIC\"SINK A\"", "yellow")
        colored_print("Loading module-remap-source for microphone sink", "yellow")
        source_info = subprocess.check_output(["pactl", "list", "short", "sources"]).decode()
        master_source = source_info.split("alsa_input")[1].split("\t")[0]
        run_command(f"pactl load-module module-remap-source source_name={SINKA} master={master_source}")

    # Load echo cancellation module
        colored_print("Load module-echo-cancel", "yellow")
        run_command(f"pactl load-module module-echo-cancel sink_name=echo-cancell master={SINKA} aec_method=webrtc aec_args=analog_gain_control=0,digital_gain_control=0")

        # Load Ladspa effects
        colored_print("Load module-ladspa-sink for pitch", "yellow")
        run_command(f"pactl load-module module-ladspa-sink sink_name=LADSPA_pitch plugin=tap_pitch label=tap_pitch control=0.1,0.1,0.5,0.1,0.1 master=echo-cancell")
        colored_print("Load module-ladspa-sink for autotalent", "yellow")
        run_command(f"pactl load-module module-ladspa-sink sink_name=ladspa_talent plugin=tap_autotalent label=autotalent master=LADSPA_pitch")
        colored_print("Load module-ladspa-sink for declipper", "yellow")
        run_command(f"pactl load-module module-ladspa-sink sink_name={SINKB} plugin=declip_1195 label=declip master=LADSPA_pitch")

        # Set source volume
        run_command(f"pactl set-source-volume {SINKA} 98%")
        run_command(f"pactl set-source-volume {SINKB} 85%")

        # Load loopback module
        run_command(f"pactl load-module module-loopback master={SINKB}")

        # Start downloading lyrics-video and record audio
        colored_print("Starting to download lyrics-video and record audio", "green")

        # PREPARE to Record the audio with effects applied
        os.system(f"rm -rf {input_dir}/playz/{karaoke_name}_playback*")

        if video_url:
            colored_print("[YT-DL] Received apparently a URL, gonna try get lyrics video..", "yellow")

            try:
                PLAYBETA_TITLE = subprocess.check_output(["yt-dlp", "--get-title", video_url]).decode().strip()
                print(PLAYBETA_TITLE)
            except subprocess.CalledProcessError:
                colored_print("FAILED to get title from the URL.", "red")
                colored_print("ABORT", "red")
                return

            run_command(f"yt-dlp {video_url} -o {input_dir}playz/{karaoke_name}_playback --embed-subs --progress")

            beta_playfile = subprocess.run(["ls", "-1", f"playz/{karaoke_name}_playback.*"], capture_output=True, text=True, check=True, cwd=input_dir).stdout.strip()
            playbeta_length = subprocess.run(["ffprobe", "-v", "error", "-show_entries", "format=duration", "-of", "default=noprint_wrappers=1:nokey=1", beta_playfile], capture_output=True, text=True, check=True).stdout.strip()
            print(playbeta_length)

            colored_print("PREPARE-SE PARA CANTAR EM BREVE", "yellow")
            colored_print("PREPARE-se *5sec* para cantar", "yellow")
            time.sleep(3)
            print("...2")
            time.sleep(1)
            print("...1")
            time.sleep(1)

            run_command(f"aplay {input_dir}research.wav")
            colored_print("SING!--------------------------", "yellow")
            colored_print("[FFMPEG] Video and audio Recording with effects applied...", "yellow")

            subprocess.Popen(["parec", f"--device={SINKB}"], stdout=subprocess.PIPE) | \
            subprocess.Popen(["sox", "-V6", "-t", "raw", "-r", "48000", "-b", "16", "-c", "2", "-e", "signed-integer", "-", "-t", "wav", "-r", "48000", "-b", "16", "-c", "2", "-e", "signed-integer", f"{input_dir}recz/{karaoke_name}_voc.wav", "dither", "-s"], stdin=subprocess.PIPE)

            subprocess.Popen(["ffmpeg", "-hide_banner", "-loglevel", "quiet", "-y", "-f", "v4l2", "-input_format", subprocess.run(["ffmpeg", "-loglevel", "quiet", "-hide_banner", "-formats"], capture_output=True, text=True).stdout.split("[video4linux2,v4l2,")[1].split(" ")[0], "-i", "/dev/video0", "-strict", "experimental", "-t", playbeta_length, "-b:v", "900k", f"{input_dir}recz/{karaoke_name}_voc.avi"])

            colored_print("Launch lyrics video", "yellow")
            subprocess.Popen(["ffplay", "-loglevel", "quiet", "-hide_banner", "-t", playbeta_length, beta_playfile])

        else:
            colored_print("INVALID URL --- no lyrics video", "red")
            colored_print("ABORT", "red")
            return

        colored_print("STOP RECORDING after mplayer exits", "yellow")
        colored_print("Signal FFMpeg to interrupt rendering gracefully", "yellow")
        subprocess.run(["killall", "-9", "ffplay"])
        subprocess.run(["killall", "-SIGINT", "sox"])
        subprocess.run(["killall", "-SIGINT", "ffmpeg"])

        run_command(f"ffmpeg -i {input_dir}recz/{file_name}_voc.wav -ss 1s -c copy -y {input_dir}recz/{file_name}_voc.wav")
        run_command(f"ffmpeg -i {input_dir}recz/{file_name}_voc.avi -ss 1s -c copy -y {input_dir}recz/{file_name}_voc.avi")

        colored_print("TRIGGER --- post-processing", "red")
        subprocess.run([f"{input_dir}betaKE.sh", file_name, video_url, input_dir])
        # Waiting for kill signal
        colored_print("Press 'KILL' to stop the script", "red")
        while True:
            time.sleep(1)

class App:
    def __init__(self, master):
        self.master = master
        master.title("BETAKe Karaoke Shell Interface")
        master.geometry("1024x900")  # Set window size

        # Load and display the left-aligned tux.png image
        self.left_image = tk.PhotoImage(file=os.path.join(betake_path, "tux.png"))
        self.left_image_label = tk.Label(master, image=self.left_image)
        self.left_image_label.place(x=10, y=230)

        # Load and display the right-aligned tux.png image
        self.right_image = tk.PhotoImage(file=os.path.join(betake_path, "tux.png"))
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
            
        betaREC(karaoke_name, video_url, betake_path)

    def kill_recording(self):
        # Quit the interface
        subprocess.Popen(['killall', '-HUP', 'pipewire-pulse'])
        self.master.quit()

def colored_print(text, color):
    colors = {
        "red": "\033[91m",
        "green": "\033[92m",
        "yellow": "\033[93m",
        "end": "\033[0m"
    }
    print(colors[color] + text + colors["end"])

def run_command(command):
    colored_print(command, "green")
    subprocess.run(command, shell=True)



def main():
    root = tk.Tk()
    app = App(root)
    root.mainloop()

if __name__ == "__main__":
    main()
