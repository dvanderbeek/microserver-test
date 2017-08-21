list(
    "/ping"    = function(...) "pong"
  , "/predict" = function(p, q) {
    list(
      result = predict(
        linear.model,
        newdata = data.frame(x = as.numeric(q$x))
      )[[1]]
    )
  }
  , function(...) list(exception = "catch all route")
)
