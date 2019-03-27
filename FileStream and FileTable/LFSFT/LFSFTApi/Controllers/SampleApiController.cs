namespace LFSFTApi.Controllers
{
	using LFSFTApi.Helpers;
	using Microsoft.AspNetCore.Http.Features;
	using Microsoft.AspNetCore.Mvc;
	using Microsoft.AspNetCore.WebUtilities;
	using Microsoft.Net.Http.Headers;
	using System;
	using System.IO;
	using System.Text;
	using System.Threading.Tasks;

	public class SampleApiController : ControllerBase
	{

		/// <summary>
		///    
		/// </summary>
		/// <returns></returns>
		/// <notes>
		///   Since model binding is disabled, the Upload action method doesn't accept parameters. 
		///   It works directly with the Request property of ControllerBase. 
		///   A MultipartReader is used to read each section. 
		///   The file is saved with a GUID filename and the key/value data is stored in a KeyValueAccumulator. 
		///   Once all sections have been read, the contents of the KeyValueAccumulator are used to bind the form data to a model type.
		/// </notes>
		[HttpPost("upload")]
		[DisableFormValueModelBinding]
		public async Task<IActionResult> GetUploadStream()
		{
			if (!MultipartRequestHelper.IsMultipartContentType(Request.ContentType))
			{
				return BadRequest($"Expected a multipart request, but got {Request.ContentType}");
			}

			//const string contentType = "application/octet-stream";
			string boundary = MultipartRequestHelper.GetBoundary(MediaTypeHeaderValue.Parse(Request.ContentType), FormOptions.DefaultMultipartBoundaryLengthLimit);
			MultipartReader reader = new MultipartReader(boundary, Request.Body, 80 * 1024);

			//Dictionary<string, string> sectionDictionary = new Dictionary<string, string>();
			//var memoryStream = new MemoryStream();
			//MultipartSection section;
			//while ((section = await reader.ReadNextSectionAsync()) != null)
			//{
			//	ContentDispositionHeaderValue contentDispositionHeaderValue = section.GetContentDispositionHeader();
			//	if (contentDispositionHeaderValue.IsFormDisposition())
			//	{
			//		FormMultipartSection formMultipartSection = section.AsFormDataSection();
			//		string value = await formMultipartSection.GetValueAsync();
			//		sectionDictionary.Add(formMultipartSection.Name, value);
			//	}
			//	else if (contentDispositionHeaderValue.IsFileDisposition())
			//	{
			//		// we save the file in a temporary stream
			//		var fileMultipartSection = section.AsFileSection();
			//		await fileMultipartSection.FileStream.CopyToAsync(memoryStream);
			//		memoryStream.Position = 0;
			//	}
			//}

			var formAccumulator = new KeyValueAccumulator();  // Used to accumulate all the form url encoded key value pairs in the request.
			var section = await reader.ReadNextSectionAsync();
			while (section != null)
			{
				var hasContentDispositionHeader = ContentDispositionHeaderValue.TryParse(section.ContentDisposition, out ContentDispositionHeaderValue contentDisposition);
				if (hasContentDispositionHeader)
				{
					if (MultipartRequestHelper.HasFileContentDisposition(contentDisposition))
					{
						//targetFilePath = Path.GetTempFileName();
						//using (var targetStream = System.IO.File.Create(targetFilePath))
						//{
						//	await section.Body.CopyToAsync(targetStream);
						//	_logger.LogInformation($"Copied the uploaded file '{targetFilePath}'");
						//}
					}
					else if (MultipartRequestHelper.HasFormDataContentDisposition(contentDisposition))
					{
						// Content-Disposition: form-data; name="key"value
						// Do not limit the key name length here because the multipart headers length limit is already in effect.
						var key = HeaderUtilities.RemoveQuotes(contentDisposition.Name);
						var encoding = GetEncoding(section);
						using (var streamReader = new StreamReader(section.Body, encoding, detectEncodingFromByteOrderMarks: true, bufferSize: 1024, leaveOpen: true))
						{
							// The value length limit is enforced by MultipartBodyLengthLimit
							var value = await streamReader.ReadToEndAsync();
							if (string.Equals(value, "undefined", StringComparison.OrdinalIgnoreCase)) value = string.Empty;
							formAccumulator.Append(key.Value, value);
							if (formAccumulator.ValueCount > _defaultFormOptions.ValueCountLimit)
							{
								throw new InvalidDataException($"Form key count limit {_defaultFormOptions.ValueCountLimit} exceeded.");
							}
						}
					}
				}

				// Drains any remaining section body that has not been consumed and reads the headers for the next section.
				section = await reader.ReadNextSectionAsync();
			}

			//CloudStorageAccount.TryParse(connectionString, out CloudStorageAccount cloudStorageAccount);
			//CloudBlobClient cloudBlobClient = cloudStorageAccount.CreateCloudBlobClient();
			//CloudBlobContainer cloudBlobContainer = cloudBlobClient.GetContainerReference(containerName);
			//if (await cloudBlobContainer.CreateIfNotExistsAsync())
			//{
			//	BlobContainerPermissions blobContainerPermission = new BlobContainerPermissions() { PublicAccess = BlobContainerPublicAccessType.Container };
			//	await cloudBlobContainer.SetPermissionsAsync(blobContainerPermission);
			//}
			//MyFile myFile = JsonConvert.DeserializeObject<MyFile>(sectionDictionary.GetValueOrDefault(nameof(MyFile)));
			//CloudBlockBlob cloudBlockBlob = cloudBlobContainer.GetBlockBlobReference(myFile.RelativePath);
			//using (Stream blobStream = await cloudBlockBlob.OpenWriteAsync())
			//{
			//	// Finally copy the file into the blob writable stream
			//	await memoryStream.CopyToAsync(blobStream);
			//}
			//// you can replace OpenWriteAsync by
			//// await cloudBlockBlob.UploadFromStreamAsync(memoryStream);


			//CloudBlobContainer vCloudBlobContainer = await GetCloudBlobContainer().ConfigureAwait(false);

			//MyFile myFile;
			//while ((section = await reader.ReadNextSectionAsync().ConfigureAwait(false)) != null)
			//{
			//	ContentDispositionHeaderValue contentDispositionHeaderValue = section.GetContentDispositionHeader();
			//	if (contentDispositionHeaderValue.IsFormDisposition())
			//	{
			//		FormMultipartSection formMultipartSection = section.AsFormDataSection();
			//		string value = await formMultipartSection.GetValueAsync().ConfigureAwait(false);
			//		sectionDictionary.Add(formMultipartSection.Name, value);
			//	}
			//	else if (contentDispositionHeaderValue.IsFileDisposition())
			//	{
			//		myFile = JsonConvert.DeserializeObject<MyFile>(sectionDictionary.GetValueOrDefault(nameof(MyFile)));
			//		if (myFile == default(object)) throw new InvalidOperationException();
			//		CloudBlockBlob cloudBlockBlob = vCloudBlobContainer.GetBlockBlobReference(myFile.RelativePath);
			//		Stream stream = await cloudBlockBlob.OpenWriteAsync().ConfigureAwait(false);
			//		FileMultipartSection fileMultipartSection = section.AsFileSection();
			//		await cloudBlockBlob.UploadFromStreamAsync(fileMultipartSection.FileStream).ConfigureAwait(false);
			//	}
			//}

			return Ok(); // return httpcode 200
		}


		[HttpGet]
		public FileStreamResult GetTest()
		{
			var stream = new MemoryStream(Encoding.ASCII.GetBytes("Hello World"));
			return new FileStreamResult(stream, new MediaTypeHeaderValue("text/plain"))
			{
				FileDownloadName = "test.txt"
			};
		}


		private static Encoding GetEncoding(MultipartSection section)
		{
			MediaTypeHeaderValue mediaType;
			var hasMediaTypeHeader = MediaTypeHeaderValue.TryParse(section.ContentType, out mediaType);
			// UTF-7 is insecure and should not be honored. UTF-8 will succeed in 
			// most cases.
			if (!hasMediaTypeHeader || Encoding.UTF7.Equals(mediaType.Encoding))
			{
				return Encoding.UTF8;
			}
			return mediaType.Encoding;
		}

	}
}