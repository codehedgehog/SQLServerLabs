namespace PhotoLibraryWeb
{
	using System.Configuration;
	using System.Data;
	using System.Data.SqlClient;
	using System.Data.SqlTypes;
	using System.IO;
	using System.Transactions;

	public class PhotoData
	{
		public static void InsertPhoto(int photoId, string desc, Stream source)
		{
			using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["PhotoLibraryDb"].ConnectionString))
			{
				using (SqlCommand cmd = new SqlCommand("InsertPhotoRow", conn))
				{
					using (TransactionScope ts = new TransactionScope())
					{
						cmd.CommandType = CommandType.StoredProcedure;
						cmd.Parameters.AddWithValue("@PhotoId", photoId);
						cmd.Parameters.AddWithValue("@PhotoDescription", desc);
						string serverPathName = default(string);
						byte[] serverTxnContext = default(byte[]);
						conn.Open();
						using (SqlDataReader rdr = cmd.ExecuteReader(CommandBehavior.SingleRow))
						{
							rdr.Read();
							serverPathName = rdr.GetSqlString(0).Value; //UNC format points to network share name, contain GUID value in the uniqueidentifier ROWGUIDCOL column of the BLOB's corresponding row
							serverTxnContext = rdr.GetSqlBinary(1).Value;
							rdr.Close();
						}
						conn.Close();
						using (SqlFileStream dest = new SqlFileStream(serverPathName, serverTxnContext, FileAccess.Write))
						{
							source.CopyTo(dest, 4096);
							dest.Close();
						}
						ts.Complete();
					}
				}
			}
		}

		public static byte[] SelectPhotoImage(int photoId)
		{
			byte[] photoImage = default(byte[]);
			using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["PhotoLibraryDb"].ConnectionString))
			{
				using (SqlCommand cmd = new SqlCommand("SelectPhotoImageInfo", conn))
				{
					using (TransactionScope ts = new TransactionScope())
					{
						cmd.CommandType = CommandType.StoredProcedure;
						cmd.Parameters.AddWithValue("@PhotoId", photoId);
						string serverPathName = default(string);
						byte[] serverTxnContext = default(byte[]);
						conn.Open();
						using (SqlDataReader rdr = cmd.ExecuteReader(CommandBehavior.SingleRow))
						{
							rdr.Read();
							serverPathName = rdr.GetSqlString(0).Value;
							serverTxnContext = rdr.GetSqlBinary(1).Value;
							rdr.Close();
						}
						conn.Close();
						using (SqlFileStream source = new SqlFileStream(serverPathName, serverTxnContext, FileAccess.Read))
						{
							using (MemoryStream dest = new MemoryStream())
							{
								source.CopyTo(dest, 4096);
								dest.Close();
								photoImage = dest.ToArray();
							}
							source.Close();
						}
						ts.Complete();
					}
				}
			}
			return photoImage;
		}

		public static string SelectPhotoDescription(int photoId)
		{
			string desc = default(string);
			string connStr = ConfigurationManager.ConnectionStrings["PhotoLibraryDb"].ConnectionString;
			using (SqlConnection conn = new SqlConnection(connStr))
			{
				conn.Open();
				using (SqlCommand cmd = new SqlCommand("SelectPhotoDescription", conn))
				{
					cmd.CommandType = CommandType.StoredProcedure;
					cmd.Parameters.AddWithValue("@PhotoId", photoId);
					cmd.Parameters.Add("@PhotoDescription", SqlDbType.VarChar, -1);
					cmd.Parameters["@PhotoDescription"].Direction = ParameterDirection.Output;

					cmd.ExecuteNonQuery();
					desc = cmd.Parameters["@PhotoDescription"].Value.ToString();
				}
			}
			return desc;
		}
	}
}