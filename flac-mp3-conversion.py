import os
import sys
import glob
import time
from pydub import AudioSegment # pip install pydub

music_dir = '/data/Music/Rubyripper/flac'

os.chdir(music_dir)
all_files = glob.glob('**/*.flac', recursive=True) # >= Python 3.5

print("Converting ", len(all_files), " files...")

start_time = time.time()

for music_file in all_files:
    old_relative_path = os.path.dirname(music_file)
    old_absolute_path = os.path.dirname(os.path.realpath(music_file)) + '/'

    old_filename = os.path.basename(music_file)
    new_filename = os.path.splitext(old_filename)[0] + '.mp3'

    new_path = old_absolute_path[:-len(old_relative_path)-len('/flac')-1] \
                + 'mp3/' + old_relative_path + '/'
    old_file = old_absolute_path + old_filename
    new_mp3 = old_absolute_path + new_filename
    new_mp3_correct_path = new_path + new_filename

    print(old_absolute_path + old_filename, " => ", new_file)

    AudioSegment.from_file(music_file).export(
            new_filename, format='mp3', bitrate='320k')
    os.makedirs(new_path, exist_ok=True)
    os.rename(new_mp3, new_mp3_correct_path)

print("Conversion completed in ", time.time() - start_time, " seconds.")
