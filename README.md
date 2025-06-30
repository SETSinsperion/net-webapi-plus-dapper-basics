# A Beginner's Guide to Dapper with .NET 🚀 Complete CRUD in a .NET 8 Web API using SQL Server

## Creating project

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
public int Id { get; set; }
public required string Title { get; set; }
public required string Publisher { get; set; }
public required string Developer { get; set; }
public required string Platform { get; set; }
public required DateTime ReleaseDate { get; set; }
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

> Note: **Dapper** can work with both System.Data.SqlClient and Microsoft.Data.SqlClient packages, latter one is the current, that's the reason why VS2022 marks your connection object as _deprecated_, but if you need to upgrade, simply install the Microsoft.Data.SqlClient and fix the `using` statements.

## Creating Controller

1. Create a new Controller in your Controller folder called "VideogamesController.cs".
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
        Task<VideoGame> GetByIdAsync(int id);
        Task AddAsync(VideoGame videoGame);
        Task UpdateAsync(VideoGame videoGame);
        Task DeleteAsync(int id);
    }
}
```

2. 

> Note: `[HttpGet("{id}")]` is the contraction of `[HttpGet][Route("{id}")]`.
