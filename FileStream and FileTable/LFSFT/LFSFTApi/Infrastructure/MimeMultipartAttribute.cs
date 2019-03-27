namespace LFSFTApi.Infrastructure
{
	public class MimeMultipartAttribute
	{
		public override void OnActionExecuting(HttpActionContext actionContext)
		{
			if (!actionContext.Request.Content.IsMimeMultipartContent())
			{
				throw new HttpResponseException(new HttpResponseMessage(HttpStatusCode.UnsupportedMediaType)
				);
			}
		}

		public override void OnActionExecuted(HttpActionExecutedContext actionExecutedContext)
		{

		}

	}
}
