SELECT TOP (1000) [Id]
      ,[Title]
      ,[PublisherId]
      ,[DeveloperId]
      ,[ReleaseDate]
  FROM [VideoGameDbNormalized].[dbo].[VideoGames]

SELECT
    v.[Id]
    , v.[Title]
    , p.[Name] AS Publisher
    , d.[Name] AS Developer
    , pl.[Name] AS Platform 
    , v.[ReleaseDate]
FROM
    VideoGames v INNER JOIN Publishers p
      ON v.PublisherId = p.Id INNER JOIN Developers d
      ON v.DeveloperId = d.Id INNER JOIN VideoGamesPlatforms vp
      ON v.Id = vp.VideoGameId INNER JOIN Platforms pl
      ON pl.Id = vp.PlatformId
WHERE
    v.Id = @Id

SELECT
    TOP 1 1
FROM
    VideoGames v INNER JOIN Publishers p
      ON v.PublisherId = p.Id INNER JOIN Developers d
      ON v.DeveloperId = d.Id INNER JOIN VideoGamesPlatforms vp
      ON v.Id = vp.VideoGameId INNER JOIN Platforms pl
      ON pl.Id = vp.PlatformId
WHERE
    v.[Title] = @Title
    AND p.[Name] = @Publisher
    AND d.[Name] = @Developer
    AND pl.[Name] = @Platform
    AND v.[ReleaseDate] = @ReleaseDate

USE VideoGameDbNormalized;
SELECT * FROM VideoGames;
SELECT * FROM Platforms;
SELECT * FROM Developers;
SELECT * FROM Publishers;
SELECT * FROM Reviews;
SELECT * FROM VideoGamesPlatforms;
SELECT IDENT_CURRENT('VideoGames') AS CurrentIdentity;
SELECT TOP 1 Id FROM VideoGames ORDER BY Id DESC;
SELECT CAST(SCOPE_IDENTITY() AS INT)

USE VideoGameDbNormalized
GO

IF OBJECT_ID('dbo.DeleteVideogame', 'P') IS NOT NULL
    DROP PROCEDURE dbo.DeleteVideogame;
ELSE
    PRINT 'Stored procedure does NOT exist';

CREATE PROCEDURE dbo.DeleteVideogame
    @Id INT,
    @WasDeleted BIT OUTPUT
AS
BEGIN
    BEGIN TRY
        SET NOCOUNT OFF;
        SET @WasDeleted = 0;

        BEGIN TRANSACTION;

        IF EXISTS (
            SELECT
                TOP 1 1
            FROM
                VideoGames
            WHERE
                Id = @Id
        )
        BEGIN
            -- Delete relationships Videogame - Platforms
            DELETE FROM VideoGamesPlatforms
            WHERE [VideoGameId] = @Id;

            -- Delete Videogames reviews.
            DELETE FROM [dbo].[Reviews]
            WHERE [VideoGameId] = @Id;

            -- Delete Videogames details.
            DELETE FROM [dbo].[GameDetails]
            WHERE [VideoGameId] = @Id;

            -- Delete Videogame records
            DELETE FROM VideoGames
            WHERE [Id] = @Id;

            IF @@ROWCOUNT > 0
                SET @WasDeleted = 1;
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        -- Raise the error up to the caller
        THROW;
    END CATCH
END;
