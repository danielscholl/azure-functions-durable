using System.Net;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Primitives;

public static IActionResult Run(HttpRequest req, TraceWriter log)
{
    log.Info("Ping Test Executed.");
    return (ActionResult)new OkObjectResult($"Pong");
}
