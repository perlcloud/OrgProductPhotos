USE /*Enter Database Name*/
GO

/****** Object:  Table [dbo].[PT_ProductImageData]    Script Date: 11/26/2018 3:55:00 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PT_ProductImageData](
	[Path] [nvarchar](255) NOT NULL,
	[FileName] [nvarchar](255) NOT NULL,
	[ExportDate] [datetime] NULL,
	[MatchID] [nvarchar](255) NULL,
	[AngleCodePART] [nvarchar](255) NULL,
	[AngleCode]  AS (case when NOT [AngleCodePART] like '%-%' then [AngleCodePART] else left([AngleCodePART],charindex('-',[AngleCodePART])-(1)) end)
) ON [PRIMARY]
GO
