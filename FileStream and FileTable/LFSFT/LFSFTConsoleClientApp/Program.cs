
namespace LFSFTConsoleClientApp
{
	using Newtonsoft.Json;
	using System;
	using System.IO;
	using System.Net.Http;
	using System.Text;
	using System.Threading.Tasks;

	internal static class Program
	{

		private const string filePath = @"D:\Test.txt";
		private const string baseAddress = "http://localhost:5000";

		private static async Task Main(string[] args)
		{
			Console.WriteLine($"Test starts at {DateTime.Now.ToString("o")}");
			FileStream fileStream = new FileStream(filePath, FileMode.Open);
			MyFile vFile = new MyFile()
			{
				Length = 0,
				RelativePath = "Test.txt"
				//Path = "https://c2calrsbackup.blob.core.windows.net/containername/Test.txt",
			};
			await UploadStream(vFile, fileStream);
			Console.WriteLine($"Test ends at {DateTime.Now.ToString("o")}");
			Console.Write("Press any key to exit...");
			Console.ReadKey();

		}

		private static async Task UploadStream(MyFile myFile, Stream stream)
		{
			try
			{
				using (HttpClient httpClient = new HttpClient()) // instance should be shared
				{
					httpClient.BaseAddress = new Uri("https://localhost:5000");
					using (MultipartFormDataContent multipartFormDataContent = new MultipartFormDataContent())
					{
						multipartFormDataContent.Add(new StringContent(JsonConvert.SerializeObject(myFile), Encoding.UTF8, "application/json"), nameof(MyFile));
						// Here we add the file to the multipart content.
						// The third parameter is required to match the 'IsFileDisposition()' but could be anything
						multipartFormDataContent.Add(new StreamContent(stream), "stream", nameof(MyFile));
						HttpResponseMessage httpResult = await httpClient.PostAsync("api/values/upload", multipartFormDataContent).ConfigureAwait(false);
						httpResult.EnsureSuccessStatusCode();
						// We don't need any result stream anymore
					}
				}
			}
			catch (Exception e)
			{
				Console.WriteLine(e.Message);
			}
		}

	}
}
