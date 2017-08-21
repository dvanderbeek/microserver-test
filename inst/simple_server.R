library(methods)
devtools::load_all()
load(file = "inst/Linear_model.rda")

routes <- source('inst/routes.R')$value

cat('listening..\n')
microserver::run_server(routes, 33399)
