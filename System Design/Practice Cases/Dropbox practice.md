- How will users be able to upload files?

The client will start an Upload Request, the Api Gateway will validate the request, it will check the authentication, permission, and any security validation, if everything is fine, the request will pass to the Upload handler, the upload handler will request an pre-signed url to Amazon S3, this pre-signe url will be returned to the Client and the client will be in charge to upload the file directly to Amazon S3, Amazon S3 will be in charge to handle the multipart upload and any fault-tolerance, when the upload finish, the client will have the storage id returned by Amazon S3, so the client will send all the file metadata, including the storage if, to the upload handler, the upload handler will be in charge to store all the data in the Database, and it will return a succes response.

- How will users be able to download files from remote storage?

The client will send a request to download a file, providing the ID of the file. The Api Gateway will handle the authentication, authorization and validation, if everything is fine, it will redirect the request to the Download handler. The download handler will request a signed url to Amazon S3, this signed url will be returned to the user to start the download directly from Amazon S3.

- Design how the Dropbox desktop / mobile sync agent detects edits in the user's local Dropbox folder and uploads those changes to remote storage.

There will be a File Watcher component that will detect any change in the local files, and it will trigger an update request to the application. The application will request a signed url to Amazon S3 and this will be returned to the client. The client will be in charge of uploading the updated file to Amazon S3. When the upload finishes, the client will send an update request to the application, and the application will update the metadata of file in the database.

- Design how the sync agent on a device discovers changes that happened in the cloud and applies them to the local file system.

The agent will send requests periodically (on open and every 5 minutes) to the Sync Files endpoint, with the changed_since set to the value of the local last_sync_at. This means that it will get all the files created, updated or deleted since the last sync. The client will do the required action on each file and its local database to have the same state as the server.

- How will your system handle uploading large files (up to 50GB) given the limitations of most servers and clients on the size of a POST request body?

The client will update directly to Amazon S3 bucket, this already implements support for multipart and fault-tolerance upload, which means that the client will update the file in chunks without the need for our Application to handle the request. The chunck size for the multipart upload could start with 10MB, it could change based on performance test and the cloud service restriccions.

- How would your system handle a scenario where a user starts a large file upload on one device, then wants to continue the upload from a different device? What metadata would you need to track and how would you ensure the upload can be resumed correctly?

In this case, we will need to send the track of the upload to the server, and store it in the Database, and the client could get the state of the upload in the sync process. The client could resume the upload process based on the information provided by the server. It could have the chunk size and the chunk index uploaded. 

- Uploading large files can also be challenging due to network interruptions. How does your design allow users to resume an interrupted upload without starting over from scratch?

The client will track the upload process in its local database, saving the chunk size, the index of the uploaded successfully and the uploadedId and ETag provided by Amazon S3.  This will help resume the upload.

- How can we reduce bandwidth usage and make the sync process faster than downloading full files each time they change?

We can have versioning of the files and download only the diff data.
