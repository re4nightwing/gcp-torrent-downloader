# Torrent Direct Download with GCP

### Download torrents
1. Start up a gcp compute engine (Ubuntu 20.04 LTS) with required storage. (cpu, ram doesn't effect the process that much)
2. SSH to the VM instance and download the script.
   
```
wget https://raw.githubusercontent.com/re4nightwing/gcp-torrent-downloader/main/setup-nginx.sh
```
3. Run the script

```
sudo chmod +x setup-nginx.sh
sudo ./setup-nginx.sh
```

- This script will install nginx & transmission-daemon on the VM and will config both of them.
- Go through the script *recommended*

4. Add torrents to transmission using torrent files or magnet links.

```
transmission-remote -a "<torrent-file or magnet link>" <anyother parameters>
```
- Download location is set to $HOME of the user. If you want to change that edit the transmission config file or add `-w <download-dir>` to the add command.

5. Check the download status using,

```
transmission-remote -l
```
6. You can check which files are downloading and can set files to not download using following commands. *If any files does not list, wait some time and check again.*

```
transmission remote -t <torrent-id> -f #lists the files
transmission-remote -t <torrent-id> --no-get <file indexes> #excludes the files from downloading
```

7. In order to remove a torrent(s) use,

```
transmission-remote -t <torrent-id> -r 
transmission-remote -t <torrent-id,torrent-id> -r 
transmission-remote -t all -r #removes all 
```

### Use nginx to download files

1. Move or copy the files to /var/www/downloads/ directory after the torrent is completed.

```
sudo mv ./The-Game /var/www/downloads
```
2. Now go to `http://<VM-external-IP>/downloads/` link to view and download the files.

### Zip the downloaded files (Recommended)

1. It is easier to download files when all files are zipped in to multiple zips. To do that use,

```
zip -r -v -s <maximum zip size> <zip-name.zip> <directory/to/zip/>
zip -r -v -s 10G The-Game.zip ./The-Game/
```
**Zipping is a cpu/memory heavy process. Use wisely. Will take a long time if the resources are low.**

### Upload to google storage (Recommended for cost cutting)

1. Initialize gcloud on the VM.

```
gcloud auth login
```
2. Create a cloud storage bucket with preferred region using,

```
gsutil mb gs://bucket-name #Bucket name has to be unique
```
or create one manually from the web interface.

3. Copy the files or zips to the cloud storage.

```
gsutil cp -r <path/to/downloaded/directory> gs://<bucket-name>
```
*This will take some time but will help with the overall cost if you are going to keep the files for long term accessing.*

### FAQ

*Feel free to open up a issue if anything goes wrong. I'm happy to help you out and will update here for future reference.*

### Contribute

- I'm new to shell scripting so if there're anyways to improve the script or add more to automate the process please create a pull request.
- If you're familiar with how transmission works please contribute to the script to configure the transmission application for optimal performance.

## Important!!

If you are going to use this method please think of seeding the torrent after downloading. It won't cost you much compared to your personal network connection costs and the GCP's upload speeds are really high.
