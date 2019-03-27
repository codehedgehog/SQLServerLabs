namespace PhotoLibraryWeb
{
	using System;
	using System.Web.UI;

	public partial class PhotoPage : Page
	{
		protected void saveLinkButton_Click(object sender, EventArgs e)
		{
			if (!photoFileUpload.HasFile)
			{
				return;
			}
			int photoId = int.Parse(savePhotoIdTextBox.Text);
			string desc = descriptionTextBox.Text;
			System.IO.Stream httpStream = photoFileUpload.FileContent;

			PhotoData.InsertPhoto(photoId, desc, httpStream);
		}

		protected void loadLinkButton_Click(object sender, EventArgs e)
		{
			int photoId = int.Parse(loadPhotoIdTextBox.Text);

			string photoDescription = PhotoData.SelectPhotoDescription(photoId);

			photoImage.ImageUrl = string.Format("/PhotoHandler.ashx?photoId={0}", photoId);
			photoDescriptionLabel.Text = photoDescription;
		}
	}
}