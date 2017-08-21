library(methods)
devtools::load_all()
load(file = "inst/Linear_model.rda")

routes <- list(
    "/ping"        = function(...) "pong"
  , "/predict" = function(p, q) { list(result = predict(linear.model, newdata = data.frame(x = as.numeric(q$x)))) }
  , function(...) list(exception = "catch all route")
)
cat('listening..\n')
microserver::run_server(routes, 33399)
