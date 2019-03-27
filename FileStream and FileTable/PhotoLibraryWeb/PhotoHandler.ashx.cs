namespace PhotoLibraryWeb
{
	using System.IO;
	using System.Net.Mime;
	using System.Web;

	public class PhotoHandler : IHttpHandler

	{
		public void ProcessRequest(HttpContext context)
		{
			if (!int.TryParse(context.Request.QueryString["photoId"], out int photoId))
			{
				return;
			}
			byte[] bytes = PhotoData.SelectPhotoImage(photoId);
			context.Response.ContentType = MediaTypeNames.Image.Jpeg;
			context.Response.BufferOutput = false;
			context.Response.AddHeader("content-length", bytes.Length.ToString());  // not necessary, but nice to let the client know
			using (MemoryStream ms = new MemoryStream(bytes))
			{
				ms.CopyTo(context.Response.OutputStream);
			}
		}

		public bool IsReusable => false;
	}
}