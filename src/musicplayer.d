module musicplayer;

pragma(lib, "winmm");

import std.stdio;
import std.string;
import std.conv;
import core.sys.windows.windows;
import core.sys.windows.mmsystem;

void main(string[] args) {
    MusicPlayer mp = new MusicPlayer();
    mp.main(args);
}

class MusicPlayer {
    private bool playing = false;
    private bool opened = false;
    
    public this() { }

    public void main(string[] args) {
        writeln("CLI Music player by Deen O'Connor \nSupports WAV and MP3 files");
        writeln("Type file path to play, help or ? to print commands or quit to exit: ");
        
        bool quit = false;
        while(!quit) {
            write("[COMMAND]> ");
            string command = readln().chop();

            switch (command) {
            case "quit":
                quit = true;
            break;
            case "help":
            case "?":
                this.help();
            break;
            case "volume":
                this.volume();
            break;
            case "stop":
                this.stop();
            break;
            case "resume":
                this.resume();
            break;
            case "close":
                this.close();
            break;
            default:
                this.play(command);
            break;
            }
        }
    }

    private void help() {
        writeln("CLI Music player by Deen O'Connor\nSupported commands:\nstop - stop playing\nresume - continue playing\nclose - close music file\nvolume then X - set volume\nMusic file path MUST NOT CONTAIN SPACES!");
    }

    private void volume() {
        if (!this.opened) {
            writeln("No file opened, no context to change volume of");
        }
        else {
            write("Enter new volume (0-1000): ");
            string vol = readln().chop();
            try {
                int volume = to!int(vol);
                if (volume < 0 || volume > 1000) {
                    writeln("Incorrect value! No changes will be made!");
                    return;
                }
            } catch (ConvException ex) {
                writeln("Incorrect value! No changes will be made!");
                return;
            }
            uint mciErr = mciSendString(cast(wchar*)wtext("setaudio currentsong volume to " ~ vol), null, 0u, null);
            if (mciErr == 0) {
                writeln("Volume updated");
            }
            else this.handleErr(mciErr);
        }
    }

    private void stop() {
        if (this.playing) {
            uint mciErr = mciSendString(cast(wchar*)"stop currentsong"w, null, 0u, null);
            if (mciErr == 0) {
                writeln("Stopped");
                this.playing = false;
            }
            else this.handleErr(mciErr);
        }
        else {
            writeln("Not playing, nothing to stop");
        }
    }

    private void resume() {
        if (this.playing) {
            writeln("Already playing");
        }
        else if (!this.opened) {
            writeln("No file loaded, nothing to resume");
        }
        else {
            uint mciErr = mciSendString(cast(wchar*)"resume currentsong"w, null, 0u, null);
            if (mciErr == 0) {
                writeln("Resumed");
                this.playing = true;
            }
            else this.handleErr(mciErr);
        }
    }

    private void close() {
        if (!this.opened) {
            writeln("No file loaded, nothing to close");
        }
        else {
            uint mciErr = mciSendString(cast(wchar*)"close currentsong"w, null, 0u, null);
            if (mciErr == 0) {
                writeln("Closed");
                this.playing = false;
                this.opened = false;
            }
            else this.handleErr(mciErr);
        }
    }

    private void play(string path) {
        if (!this.playing && !this.opened) {
            uint mciErr = mciSendString(cast(wchar*)wtext("open " ~ path ~ " type mpegvideo alias currentsong"), null, 0u, null);
            if (mciErr == 0) {
                this.opened = true;
                writeln("Playing " ~ path);
                uint mcErr = mciSendString(cast(wchar*)"play currentsong"w, null, 0u, null);
                if (mcErr == 0) {
                    this.playing = true;
                }
                else {
                    this.handleErr(mciErr);
                }
            }
            else {
                this.handleErr(mciErr);
            }
        }
        else {
            writeln("Close current file before opening a new one");
        }
    }

    private void handleErr(uint mciErr) {
        auto errs = to!string(mciErr, 16);
        writeln("Error 0x" ~ errs ~ "!");
    }

}
