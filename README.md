# Torrent Direct Download with GCP

### Download torrents
1. Start up a gcp compute engine (Ubuntu 20.04 LTS) with the required storage. (cpu and RAM don't effect the process that much)
2. SSH to the VM instance and download the script.
   
```
wget https://raw.githubusercontent.com/re4nightwing/gcp-torrent-downloader/main/setup-nginx.sh
```
3. Run the script

```
sudo chmod +x setup-nginx.sh
sudo ./setup-nginx.sh
```

- This script will install nginx & transmission-daemon on the VM and will configure both of them.
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
6. You can check which files are downloading and can set files to not download using the following commands. *If any files do not list, wait some time and check again.*

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

> 1. Move or copy the files to /var/www/downloads/ directory after the torrent is completed.
> 
> ```
> sudo mv ./The-Game /var/www/downloads
> ```
> 2. Now go to `http://<VM-external-IP>/downloads/` link to view and download the files.

As of the latest update above functionality has been replaced with web-app. (The shell file will create this same as before.)

### Setup the Web Application for downloads

The basic purpose of the web application is to list out download links for uploaded files in the gcp bucket. This web application is a minimal site that is created using the Flask web framework. 

1. copy the web-app files to the server
2. Replace the URL in the `run.py` file with your bucket URL. Eg: https://storage.googleapis.com/<BUCKET_NAME> # Do not add "/" to the end of the URL. 
3. create a virtual environment and install `requests, flask, gunicorn`
4. config the nginx to serve the gunicorn server.
   ```sh
   server{
        server_name ServerName;

        location / {
                proxy_pass http://localhost:8000;  # Forward requests to the Flask app
                include /etc/nginx/proxy_params;
                proxy_redirect off;
        }

        location ^~ /static/ {
                include /etc/nginx/mime.types;
                root /home/app/;
        }
   }
   ```
5. **Optional**: Setup supervisor to automate the server startup.
   ```
   [program:tor-site]
   directory=/home/app
   command=/home/app/venv/bin/gunicorn -w 5 run:app
   user=USER_NAME
   autostart=true
   autorestart=true
   stopasgroup=true
   killasgroup=true
   stderr_logfile=/var/log/supervisor/tor-site.err.log
   stderr_logfile_maxbytes=10MB
   stdout_logfile=/var/log/supervisor/tor-site.out.log
   stdout_logfile_maxbytes=10MB
   ```

### Zip the downloaded files (Recommended)

1. It is easier to download files when all files are zipped into multiple zips. To do that use,

```
zip -r -v -0 -s <maximum zip size> <zip-name.zip> <directory/to/zip/>
zip -r -v -0 -s 10G The-Game.zip ./The-Game/ #will split the whole directory into 10 GB-sized zips.
```
**Zipping is a CPU/memory-heavy process. Use wisely. Will take a long time if the resources are low.**

### Upload to Google Storage (Recommended for cost-cutting)

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
*This will take some time but will help with the overall cost if you are going to keep the files for long-term access.*

### FAQ

*Feel free to open up an issue if anything goes wrong. I'm happy to help you out and will update you here for future reference.*

### Contribute

- I'm new to shell scripting so if there's any way to improve the script or add more to automate the process please create a pull request.
- If you're familiar with how transmission works please contribute to the script to configure the transmission application for optimal performance.

## Important!!

If you are going to use this method please think of seeding the torrent after downloading. It won't cost you much compared to your personal network connection costs and the GCP's upload speeds are really high.
