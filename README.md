# A Beginner's Guide to Dapper with .NET 🚀 Complete CRUD in a .NET 8 Web API using SQL Server

## Credits of the practice content

Hello! I hope you're well and this repo will help you to understand the basics of the .NET 8 ASP.NET Core + Dapper + SqlServer. The core of this practice is the next tutorial (a lot of thanks):

- Channel: Patrick God - YouTube.
- URL: https://youtu.be/hi1M-8LcjOw?si=i2UswITOCmbyspVJ

Download the repo to follow the README.

### What I've contributed

- SqlServer 2019 dockerized.
- Due to the lack of the _VideoGamesDbSimple_ BAK or SQL creation and insert queries, I've got from the video's project the _VideoGamesDbNormalized.sql_, with the CREATE DATABASE and INSERT queries.
- Code according to the _VideoGamesDbNormalized_ DB.

## Run a SqlServer Docker container

1. With the Docker Desktop engine active, navigate in your terminal to the _SqlServerContainerized_ folder, and run the next command: `docker compose up`.
2. If you don't have Visual Studio Code (VSCode), install it.
3. Install the _SQL Server (mssql)_ extension, to explore the local SqlServer servers.
4. Click on the left-side navbar SqlServer icon to start the extension, it propmts you a few detail about the new connection:

- Profile name (connection name): localhost_docker
- Server: localhost.
- Port: 1433.
- Connection authentication: SQL login.
- User: As it says on the .env file.
- Password: As it says on the .env file.

5. Once you have fill the connection information up, the extension shows a new active node.
6. Open the _SqlServerContainerized/VideoGamesDbNormalized.sql_ and click on the button _play_ to execute the queries, a prompt appears to select the DB connection to execute the query, select the _localhost_docker_, and ready to go with your dockerized SqlServer!

## Creating VS2022 project

In VS2022:

- Name: DapperBasics.
- Type: ASP.NET Core Web API.
- Platform: .NET 8 (LTS).
- Use Controllers: Checked (For bigger projects).

## Install Dapper

Nuget: Dapper

## Create Models

1. Create a new Folder in your project "Models".
2. Create a new C# class with the next properties:

```csharp
using System;

namespace DapperBasics.Models
{
    public class VideoGame
    {
        public int Id { get; set; }
        public required string Title { get; set; }
        public required string Publisher { get; set; }
        public required string Developer { get; set; }
        public required string Platform { get; set; }
        public required DateTime ReleaseDate { get; set; }
    }
}
```

> Note: According to the records in VideoGames table, db VideoGamesDbNormalized.

## Set your connection db

In the appsettings.json file, type the next, the _ConnectionStrings_ zone:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost:1433;Database=VideoGameDbNormalized;User Id=your_db_user;Password=your_strong_password;TrustServerCertificate=true;Trusted_Connection=true;"
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*"
}
```

## Using Repositories structure

1. Create a new Folder in your project called "Repositories".
2. Create a new C# interface with the next content:

```csharp
using Dapper;
using DapperBasics.Models;
using System.Data.SqlClient;

namespace DapperBasics.Repositories
{
    public class VideoGameRepository : IVideoGameRepository
    {
        private readonly IConfiguration _connection;

        public VideoGameRepository(IConfiguration connection)
        {
            _connection = connection;
        }

        public async Task<List<VideoGame>> GetAllAsync()
        {
            using var connection = GetConnection();
            var selectQuery = "SELECT\r\n    v.[Id]\r\n    , v.[Title]\r\n    , p.[Name] AS Publisher\r\n    , d.[Name] AS Developer\r\n    , pl.[Name] AS Platform \r\n    , v.[ReleaseDate]\r\nFROM\r\n    VideoGames v INNER JOIN Publishers p\r\n      ON v.PublisherId = p.Id INNER JOIN Developers d\r\n      ON v.DeveloperId = d.Id INNER JOIN VideoGamesPlatforms vp\r\n      ON v.Id = vp.VideoGameId INNER JOIN Platforms pl\r\n      ON pl.Id = vp.PlatformId";
            var videogames = await connection.QueryAsync<VideoGame>(selectQuery);
            
            return videogames.ToList();
        }

        public SqlConnection GetConnection()
        {
            var connectionString = _connection.GetConnectionString("DefaultConnection");
            return new SqlConnection(connectionString);
        }
    }
}
```

Where:

1. We set an class attribute referring to configuration.
2. In the method `GetConnection()` we got the connection object.
3. We got all videogames records with `QueryAsync` in `GetAllAsync`.

> Note: **Dapper** can work with both System.Data.SqlClient (old) and Microsoft.Data.SqlClient (new) packages, latter one is the current, that's the reason why VS2022 marks your connection object as _deprecated_, but if you need to upgrade, simply install the Microsoft.Data.SqlClient and fix the `using` statements.

## Creating Controller

1. Create a new Controller in your _Controller_ folder called "VideogamesController.cs".
2. Type the next content:

```csharp
using DapperBasics.Models;
using DapperBasics.Repositories;
using Microsoft.AspNetCore.Mvc;

namespace DapperBasics.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class VideogamesController : Controller
    {
    private readonly IVideoGameRepository _videoGameRepository;
        
        public VideogamesController(IVideoGameRepository videoGameRepository)
        {
            _videoGameRepository = videoGameRepository;
        }

        [HttpGet]
        public async Task<ActionResult<List<VideoGame>>> GetAllAsync()
        {
            var videogames = await _videoGameRepository.GetAllAsync();
            return Ok(videogames);
        }
    }
}
```

Where:

- We set an attribute for the IVideoGameRepository we created before.
- We received that attribute object through the constructor.
- Now we're returning videogames' data with the GET endpoint called `GetAllAsync()`.

## Registering Repositories

It's important to tell our API the existence of our repositories classes. Open the `Program.cs` file and add the next line _before_ the line `var app = builder.Build();`:

```csharp
builder.Services.AddScoped<IVideoGameRepository, VideoGameRepository>();
```

This tells the built-in Dependency Injection container from ASP.NET Core: _"Whenever someone asks for an IVideoGameRepository, for example in the Controller constructor, give them an instance of VideoGameRepository—and do it once per HTTP request"_. No need to new anything up—the framework injects it for you.

> Note: Don't forget to import the `using` statement of your repositories, for example in this case `using DapperBasics.Repositories;`.

### Service Lifetimes

Service in _builder.Services.*_ in ASP.NET Core is just a class that performs a specific task—like accessing a database, sending emails, logging, or handling business logic. These services are registered with the Dependency Injection (DI) container so they can be automatically provided (or “injected”) wherever they’re needed. There are 3 different methods to add to that container, and these methods define how long an instance of a service lives and when it gets created:

| Method         | Lifetime Scope                 | When a New Instance Is Created                                | Best For                                      |
|----------------|-------------------------------|----------------------------------------------------------------|-----------------------------------------------|
| AddTransient   | Every time it's requested     | A new instance is created every time it's injected             | Lightweight, stateless services               |
| AddScoped      | Once per HTTP request         | A new instance is created per request, reused within that request | Services tied to a single request (e.g., DbContext) |
| AddSingleton   | Once for the entire application | A single instance is created once and reused everywhere        | Shared services like config, caching          |

## CRUD completion

Let's complete the CRUD from our videogames DB:

1. Type the rest of the methods in the repositories contract:

```csharp
using DapperBasics.Models;

namespace DapperBasics.Repositories
{
    public interface IVideoGameRepository
    {
        Task<List<VideoGame>> GetAllAsync();
        Task<List<VideoGame>> GetByIdAsync(int id);
        Task<bool> ExistsAsync(VideoGame videoGame);
        Task<int> AddAsync(VideoGame videoGame);
        Task<bool> ExistsPlatform(string platform);
        Task<bool> ExistsPublisher(string publisher);
        Task<bool> ExistsDeveloper(string developer);
        Task<bool> UpdateAsync(VideoGame videoGame);
        Task<bool> DeleteAsync(int id);
    }
}
```

The reason why this interface has that methods is self explanatory; for example, the UPDATE operation in this case will occur when all IDs (Publisher, Developer, etcetera) are in the DB, that's why are methods prefix with _Exists*_.

2. Now implement the body of the IVideoGameRepository interface implementing in a class called _VideoGameRepository_:

```csharp
using Dapper;
using DapperBasics.Models;
using System.Data;
using System.Data.SqlClient;

namespace DapperBasics.Repositories
{
    public class VideoGameRepository : IVideoGameRepository
    {
        private readonly IConfiguration _connection;

        public VideoGameRepository(IConfiguration connection)
        {
            _connection = connection;
        }

        public async Task<List<VideoGame>> GetAllAsync()
        {
            using var connection = GetConnection();
            var selectQuery = "SELECT\r\n    v.[Id]\r\n    , v.[Title]\r\n    , p.[Name] AS Publisher\r\n    , d.[Name] AS Developer\r\n    , pl.[Name] AS Platform \r\n    , v.[ReleaseDate]\r\nFROM\r\n    VideoGames v INNER JOIN Publishers p\r\n      ON v.PublisherId = p.Id INNER JOIN Developers d\r\n      ON v.DeveloperId = d.Id INNER JOIN VideoGamesPlatforms vp\r\n      ON v.Id = vp.VideoGameId INNER JOIN Platforms pl\r\n      ON pl.Id = vp.PlatformId";
            var videogames = await connection.QueryAsync<VideoGame>(selectQuery);
            
            return videogames.ToList();
        }

        public async Task<List<VideoGame>> GetByIdAsync(int id)
        {
            using (var connection = GetConnection())
            {
                connection.Open();
                var selectQuery = "SELECT\r\n    v.[Id]\r\n    , v.[Title]\r\n    , p.[Name] AS Publisher\r\n    , d.[Name] AS Developer\r\n    , pl.[Name] AS Platform \r\n    , v.[ReleaseDate]\r\nFROM\r\n    VideoGames v INNER JOIN Publishers p\r\n      ON v.PublisherId = p.Id INNER JOIN Developers d\r\n      ON v.DeveloperId = d.Id INNER JOIN VideoGamesPlatforms vp\r\n      ON v.Id = vp.VideoGameId INNER JOIN Platforms pl\r\n      ON pl.Id = vp.PlatformId\r\nWHERE\r\n    v.Id = @Id";
                var parameters = new { Id = id };
                var videogames = await connection.QueryAsync<VideoGame>(selectQuery, parameters);
                return videogames.ToList();
            }
        }

        public async Task<bool> ExistsAsync(VideoGame videoGame)
        {
            using var connection = GetConnection();
            var videogameExistsQuery = @"
                SELECT TOP 1 1
                FROM VideoGames v
                INNER JOIN Publishers p ON v.PublisherId = p.Id
                INNER JOIN Developers d ON v.DeveloperId = d.Id
                INNER JOIN VideoGamesPlatforms vp ON v.Id = vp.VideoGameId
                INNER JOIN Platforms pl ON pl.Id = vp.PlatformId
                WHERE v.Title = @Title
                  AND p.Name = @Publisher
                  AND d.Name = @Developer
                  AND pl.Name = @Platform
                  AND v.ReleaseDate = @ReleaseDate";
            var parameters = new
            {
                Title = videoGame.Title.Trim(),
                Publisher = videoGame.Publisher.Trim(),
                Developer = videoGame.Developer.Trim(),
                Platform = videoGame.Platform.Trim(),
                ReleaseDate = videoGame.ReleaseDate.Date
            };
            var exists = await connection.ExecuteScalarAsync<int?>(videogameExistsQuery, parameters);

            return exists.HasValue;
        }

        private async Task<int> AddPublisherAsync(SqlConnection connection, SqlTransaction transaction, string publisher)
        {
            var publisherExistsQuery = "SELECT 1 FROM Publishers WHERE Name = @Name";
            var exists = await connection.ExecuteScalarAsync<int?>(publisherExistsQuery, new { Name = publisher }, transaction);

            if (exists.HasValue)
            {
                // Publisher already exists, return its ID
                var getPublisherIdQuery = "SELECT Id FROM Publishers WHERE Name = @Name";
                return await connection.ExecuteScalarAsync<int>(getPublisherIdQuery, new { Name = publisher }, transaction);
            }

            var insertPublisherQuery = "INSERT INTO Publishers (Name) VALUES (@Name);SELECT CAST(SCOPE_IDENTITY() AS INT);";
            var parameters = new { Name = publisher };
            return await connection.ExecuteScalarAsync<int>(insertPublisherQuery, parameters, transaction);
        }

        private async Task<int> AddDeveloperAsync(SqlConnection connection, SqlTransaction transaction, string developer)
        {
            var developerExistsQuery = "SELECT 1 FROM Developers WHERE Name = @Name";
            var exists = await connection.ExecuteScalarAsync<int?>(developerExistsQuery, new { Name = developer }, transaction);

            if (exists.HasValue)
            {
                // Developer already exists, return its ID
                var getDeveloperIdQuery = "SELECT Id FROM Developers WHERE Name = @Name";
                return await connection.ExecuteScalarAsync<int>(getDeveloperIdQuery, new { Name = developer }, transaction);
            }

            var insertDeveloperQuery = "INSERT INTO Developers (Name) VALUES (@Name);SELECT CAST(SCOPE_IDENTITY() AS INT);";
            var parameters = new { Name = developer };
            return await connection.ExecuteScalarAsync<int>(insertDeveloperQuery, parameters, transaction);
        }

        private async Task<int> AddPlatformAsync(SqlConnection connection, SqlTransaction transaction, string platform)
        {
            var platformExistsQuery = "SELECT 1 FROM Platforms WHERE Name = @Name";
            var exists = await connection.ExecuteScalarAsync<int?>(platformExistsQuery, new { Name = platform }, transaction);

            if (exists.HasValue)
            {
                // Platform already exists, return its ID
                var getPlatformIdQuery = "SELECT Id FROM Platforms WHERE Name = @Name";
                return await connection.ExecuteScalarAsync<int>(getPlatformIdQuery, new { Name = platform }, transaction);
            }

            var insertPlatformQuery = "INSERT INTO Platforms (Name) VALUES (@Name);SELECT CAST(SCOPE_IDENTITY() AS INT);";
            var parameters = new { Name = platform };
            return await connection.ExecuteScalarAsync<int>(insertPlatformQuery, parameters, transaction);
        }

        public async Task<int> AddAsync(VideoGame videoGame)
        {
            var videogameId = 0;
            using var connection = GetConnection();
            await connection.OpenAsync();
            using var transaction = connection.BeginTransaction();

            try
            {
                var platformId = await AddPlatformAsync(connection, transaction, videoGame.Platform);
                var publisherId = await AddPublisherAsync(connection, transaction, videoGame.Publisher);
                var devId = await AddDeveloperAsync(connection, transaction, videoGame.Developer);

                if (platformId > 0 && publisherId > 0 && devId > 0)
                {
                    var insertQuery = @"
                    INSERT INTO VideoGames (Title, PublisherId, DeveloperId, ReleaseDate)
                    VALUES (@Title, @PublisherId, @DeveloperId, @ReleaseDate);SELECT CAST(SCOPE_IDENTITY() AS INT);";
                    var parameters = new
                    {
                        Title = videoGame.Title,
                        PublisherId = publisherId,
                        DeveloperId = devId,
                        ReleaseDate = videoGame.ReleaseDate
                    };

                    videogameId = await connection.QuerySingleAsync<int>(insertQuery, parameters, transaction);
                    if (videogameId > 0)
                    {
                        // Reporting the new Id in the parameterized videoGame object.
                        videoGame.Id = videogameId;
                        var insertPlatformQuery = "INSERT INTO VideoGamesPlatforms (VideoGameId, PlatformId) VALUES (@VideoGameId, @PlatformId)";
                        await connection.ExecuteAsync(insertPlatformQuery, new { VideoGameId = videogameId, PlatformId = platformId }, transaction);
                    }
                }

                transaction.Commit();
            } catch(Exception e)
            {
                transaction.Rollback();
                throw new Exception("An error occurred while adding the video game.", e);
            }

            return videogameId;
        }

        public async Task<bool> ExistsPlatform(string platform)
        {
            using var connection = GetConnection();
            var query = "SELECT 1 FROM Platforms WHERE Name = @Name";
            var exists = await connection.ExecuteScalarAsync<int?>(query, new { Name = platform });
            return exists.HasValue;
        }

        public async Task<bool> ExistsPublisher(string publisher)
        {
            using var connection = GetConnection();
            var query = "SELECT 1 FROM Publishers WHERE Name = @Name";
            var exists = await connection.ExecuteScalarAsync<int?>(query, new { Name = publisher });
            return exists.HasValue;
        }

        public async Task<bool> ExistsDeveloper(string developer)
        {
            using var connection = GetConnection();
            var query = "SELECT 1 FROM Developers WHERE Name = @Name";
            var exists = await connection.ExecuteScalarAsync<int?>(query, new { Name = developer });
            return exists.HasValue;
        }

        public async Task<bool> UpdateAsync(VideoGame videoGame)
        {
            using var connection = GetConnection();
            await connection.OpenAsync();
            using var transaction = connection.BeginTransaction();

            try
            {
                // Getting the IDs of Publisher, Developer, Platform
                var publisherId = await AddPublisherAsync(connection, transaction, videoGame.Publisher);
                var developerId = await AddDeveloperAsync(connection, transaction, videoGame.Developer);
                var platformId = await AddPlatformAsync(connection, transaction, videoGame.Platform);

                // Update the main VideoGame table
                var updateQuery = @"
                    UPDATE VideoGames
                    SET Title = @Title,
                        PublisherId = @PublisherId,
                        DeveloperId = @DeveloperId,
                        ReleaseDate = @ReleaseDate
                    WHERE Id = @Id";

                var updateParams = new
                {
                    Title = videoGame.Title.Trim(),
                    PublisherId = publisherId,
                    DeveloperId = developerId,
                    ReleaseDate = videoGame.ReleaseDate.Date,
                    Id = videoGame.Id
                };

                var rows = await connection.ExecuteAsync(updateQuery, updateParams, transaction);
                if (rows == 0)
                {
                    transaction.Rollback();
                    return false; // Game not found
                }

                // Clear existing platform relations
                await connection.ExecuteAsync(
                    "DELETE FROM VideoGamesPlatforms WHERE VideoGameId = @Id",
                    new { Id = videoGame.Id },
                    transaction);

                // Reinsert the updated platform
                await connection.ExecuteAsync(
                    "INSERT INTO VideoGamesPlatforms (VideoGameId, PlatformId) VALUES (@VideoGameId, @PlatformId)",
                    new { VideoGameId = videoGame.Id, PlatformId = platformId },
                    transaction);

                transaction.Commit();
                return true;
            }
            catch
            {
                transaction.Rollback();
                throw;
            }
        }

        public async Task<bool> DeleteAsync(int id)
        {
            using var connection = GetConnection();

            var deleteSpQuery = "DeleteVideogame";
            var parameters = new DynamicParameters();
            parameters.Add("@Id", id);
            parameters.Add(
                "@WasDeleted",
                dbType: DbType.Boolean,
                direction: ParameterDirection.Output
            );

            await connection.ExecuteAsync(
                deleteSpQuery,
                parameters,
                commandType: CommandType.StoredProcedure
            );

            var deleted = parameters.Get<bool>("@WasDeleted");

            return deleted;
        }

        public SqlConnection GetConnection()
        {
            var connectionString = _connection.GetConnectionString("DefaultConnection");
            return new SqlConnection(connectionString);
        }
    }
}
```

Where `GetConnection()` returns SqlServer connection objects from the DefaultConnection connection string. Dapper connection object has the next methods to execute raw SQL querys:

- `OpenAsync`: For open explicity the connection asynchronously, it's neccesary to open _manuallly_ when you do more that one Dapper query methods.
- `QueryAsync`: For executing SELECT statements that return records.
- `ExecuteAsync`: For executing the another SQL statements.
- `ExecuteScalarAsync`: For executing SELECT statements that _scalars_ (int, string, bit), often used to SQL queries that tests existence of rows in a table (SELECT TOP 1 1).

Let's finish our webapi with the endpoint's body:

```csharp
using DapperBasics.Models;
using DapperBasics.Repositories;
using Microsoft.AspNetCore.Mvc;

namespace DapperBasics.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class VideogamesController : Controller
    {
        private readonly IVideoGameRepository _videoGameRepository;

        public VideogamesController(IVideoGameRepository videoGameRepository)
        {
            _videoGameRepository = videoGameRepository;
        }

        [HttpGet]
        public async Task<ActionResult<List<VideoGame>>> GetAllAsync()
        {
            var videogames = await _videoGameRepository.GetAllAsync();
            return Ok(videogames);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<List<VideoGame>>> GetByIdAsync(int id)
        {
            var videogames = await _videoGameRepository.GetByIdAsync(id);
            if (videogames == null || videogames.Count == 0)
            {
                return NotFound($"Videogame with ID = {id} doesn't exists, try it with a different one.");
            }

            return Ok(videogames);
        }

        [HttpPost]
        public async Task<IActionResult> AddAsync(VideoGame videoGame)
        {
            // Check for duplicates
            if (await _videoGameRepository.ExistsAsync(videoGame))
                return Conflict("A game with the same details already exists.");

            try
            {
                var id = await _videoGameRepository.AddAsync(videoGame);
                return Created($"api/Videogames/{id}", videoGame);
            }
            catch (Exception e)
            {
                return StatusCode(
                    500,
                    "Something went wrong while adding the video game."
                );
            }
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateAsync(int id, VideoGame videoGame)
        {
            if (id != videoGame.Id)
                return BadRequest("ID mismatch between route and payload.");

            var existingGames = await _videoGameRepository.GetByIdAsync(id);

            if (existingGames == null || existingGames.Count == 0)
            {
                return NotFound($"Videogame with ID = {id} doesn't exist, try it with a different one.");
            }

            var existingPublisher = await _videoGameRepository.ExistsPublisher(videoGame.Publisher);

            if (!existingPublisher)
            {
                return NotFound($"Publisher {videoGame.Publisher} doesn't exist, try it with a different one.");
            }

            var existingDev = await _videoGameRepository.ExistsDeveloper(videoGame.Developer);

            if (!existingDev)
            {
                return NotFound($"Developer {videoGame.Developer} doesn't exist, try it with a different one.");
            }

            var existingPlatform = await _videoGameRepository.ExistsPlatform(videoGame.Platform);

            if (!existingPlatform)
            {
                return NotFound($"Platform {videoGame.Platform} doesn't exist, try it with a different one.");
            }

            try
            {
                var updated = await _videoGameRepository.UpdateAsync(videoGame);
                return updated ? NoContent() : NotFound();
            }
            catch (Exception e)
            {
                return StatusCode(500, "Error while updating the video game.");
            }
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteAsync(int id)
        {
            try
            {
                var deleted = await _videoGameRepository.DeleteAsync(id);
                return deleted
                    ? NoContent()
                    : NotFound($"Videogame with ID {id} wasn't found in the database.");
            }
            catch (Exception e)
            {
                return StatusCode(500, "Error while deleting the video game.");
            }
        }
    }
}
```

- Each CRUD operation has its endpoint: HttpGet (Get all videogames and 1 videogame by Id), HttpPost (create), HttpPut (write/update) and HttpDelete (delete).
- Each endpoint has its own returning HTTP codes:

  - Ok: HTTP 200.
  - Created/CreatedAtAction: HTTP 201.
  - NoContent: HTTP 204.
  - StatusCode(status_code_int, message): Any HTTP status code with a message.
  - NotFound: HTTP 404.
  - BadRequest: HTTP 400.
  - Conflict: HTTP 409.

> Note: `[HttpGet("{id}")]` is the contraction of `[HttpGet][Route("{id}")]`.

## Run your webapi

Now it's time to run your webapi so you can make requests for your database _VideoGamesDbNormalized_:

- You can execute your solution in two ways:

a. Click on the _http play_ button: Runs your webapi with the VS2022 debbuger capabilities, for example using breakpoints and showing the logs from your webapi server via a terminal window.
b. Click on the _play_ button: Runs the webapi w/o debbuging, closing the compilation logs and executing the server in background.

Either one or another option opens an instance of your default browser, opening a tab with the _Swagger API tester application_, or you can use any http client like _Thunder Client (VSCode Extension)_.

> Note: Sometimes the `AddSync()` method surprise you when the new ID jumps from the 10 to 1000 or more, this is because the cache behavior in the Docker enviroment. To reset the ID sequence, use the next T-SQL statement: 

```sql
DBCC CHECKIDENT ('VideoGames', RESEED, 10);
```

This tells SQL Server _The last ID used was 10, so the next one should be 11_. Only do this if you're sure there are no higher IDs already in the table. To check the last ID value moreover the SELECT you can query the table metadata:

```sql
SELECT IDENT_CURRENT('VideoGames') AS CurrentIdentity;
```
