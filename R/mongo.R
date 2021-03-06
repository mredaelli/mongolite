#' MongoDB collection client
#'
#' Connect to a MongoDB collection. Returns a [mongo] connection object with
#' methods listed below. The [mongolite user manual](https://jeroen.github.io/mongolite/)
#' is the best place to get started.
#'
#' @export
#' @aliases mongolite
#' @references [Mongolite User Manual](https://jeroen.github.io/mongolite/)
#' @param url address of the mongodb server in mongo connection string
#' [URI format](http://docs.mongodb.org/manual/reference/connection-string)
#' @param db name of database
#' @param collection name of collection
#' @param verbose emit some more output
#' @param options additional connection options such as SSL keys/certs.
#' @return Upon success returns a pointer to a collection on the server.
#' The collection can be interfaced using the methods described below.
#' @examples # Connect to mongolabs
#' con <- mongo("mtcars", url = "mongodb://readwrite:test@ds043942.mongolab.com:43942/jeroen_test")
#' if(con$count() > 0) con$drop()
#' con$insert(mtcars)
#' stopifnot(con$count() == nrow(mtcars))
#'
#' # Query data
#' mydata <- con$find()
#' stopifnot(all.equal(mydata, mtcars))
#' con$drop()
#'
#' # Automatically disconnect when connection is removed
#' rm(con)
#' gc()
#'
#' \dontrun{
#' # dplyr example
#' library(nycflights13)
#'
#' # Insert some data
#' m <- mongo(collection = "nycflights")
#' m$drop()
#' m$insert(flights)
#'
#' # Basic queries
#' m$count('{"month":1, "day":1}')
#' jan1 <- m$find('{"month":1, "day":1}')
#'
#' # Sorting
#' jan1 <- m$find('{"month":1,"day":1}', sort='{"distance":-1}')
#' head(jan1)
#'
#' # Sorting on large data requires index
#' m$index(add = "distance")
#' allflights <- m$find(sort='{"distance":-1}')
#'
#' # Select columns
#' jan1 <- m$find('{"month":1,"day":1}', fields = '{"_id":0, "distance":1, "carrier":1}')
#'
#' # List unique values
#' m$distinct("carrier")
#' m$distinct("carrier", '{"distance":{"$gt":3000}}')
#'
#' # Tabulate
#' m$aggregate('[{"$group":{"_id":"$carrier", "count": {"$sum":1}, "average":{"$avg":"$distance"}}}]')
#'
#' # Map-reduce (binning)
#' hist <- m$mapreduce(
#'   map = "function(){emit(Math.floor(this.distance/100)*100, 1)}",
#'   reduce = "function(id, counts){return Array.sum(counts)}"
#' )
#'
#' # Stream jsonlines into a connection
#' tmp <- tempfile()
#' m$export(file(tmp))
#'
#' # Remove the collection
#' m$drop()
#'
#' # Import from jsonlines stream from connection
#' dmd <- mongo("diamonds")
#' dmd$import(url("http://jeroen.github.io/data/diamonds.json"))
#' dmd$count()
#'
#' # Export
#' dmd$drop()
#' }
#' @section Methods:
#' \describe{
#'   \item{\code{aggregate(pipeline = '{}', handler = NULL, pagesize = 1000)}}{Execute a pipeline using the Mongo aggregation framework.}
#'   \item{\code{count(query = '{}')}}{Count the number of records matching a given \code{query}. Default counts all records in collection.}
#'   \item{\code{distinct(key, query = '{}')}}{List unique values of a field given a particular query.}
#'   \item{\code{drop()}}{Delete entire collection with all data and metadata.}
#'   \item{\code{export(con = stdout(), bson = FALSE)}}{Streams all data from collection to a \code{\link{connection}} in \href{http://ndjson.org}{jsonlines} format (similar to \href{http://docs.mongodb.org/v2.6/reference/mongoexport/}{mongoexport}). Alternatively when \code{bson = TRUE} it outputs the binary \href{http://bsonspec.org/faq.html}{bson} format (similar to \href{http://docs.mongodb.org/manual/reference/program/mongodump/}{mongodump}).}
#'   \item{\code{find(query = '{}', fields = '{"_id" : 0}', sort = '{}', skip = 0, limit = 0, handler = NULL, pagesize = 1000)}}{Retrieve \code{fields} from records matching \code{query}. Default \code{handler} will return all data as a single dataframe.}
#'   \item{\code{import(con, bson = FALSE)}}{Stream import data in \href{http://ndjson.org}{jsonlines} format from a \code{\link{connection}}, similar to the \href{http://docs.mongodb.org/v2.6/reference/mongoimport/}{mongoimport} utility. Alternatively when \code{bson = TRUE} it assumes the binary \href{http://bsonspec.org/faq.html}{bson} format (similar to \href{http://docs.mongodb.org/manual/reference/program/mongorestore/}{mongorestore}).}
#'   \item{\code{index(add = NULL, remove = NULL)}}{List, add, or remove indexes from the collection. The \code{add} and \code{remove} arguments can either be a field name or json object. Returns a dataframe with current indexes.}
#'   \item{\code{info()}}{Returns collection statistics and server info (if available).}
#'   \item{\code{insert(data, pagesize = 1000, stop_on_error = TRUE, ...)}}{Insert rows into the collection. Argument 'data' must be a data-frame, named list (for single record) or character vector with json strings (one string for each row). For lists and data frames, arguments in \code{...} get passed to \code{\link[jsonlite:toJSON]{jsonlite::toJSON}}}
#'   \item{\code{iterate(query = '{}', fields = '{"_id":0}', sort = '{}', skip = 0, limit = 0)}}{Runs query and returns iterator to read single records one-by-one.}
#'   \item{\code{mapreduce(map, reduce, query = '{}', sort = '{}', limit = 0, out = NULL, scope = NULL)}}{Performs a map reduce query. The \code{map} and \code{reduce} arguments are strings containing a JavaScript function. Set \code{out} to a string to store results in a collection instead of returning.}
#'   \item{\code{remove(query = "{}", multiple = FALSE)}}{Remove record(s) matching \code{query} from the collection.}
#'   \item{\code{rename(name, db = NULL)}}{Change the name or database of a collection. Changing name is cheap, changing database is expensive.}
#'   \item{\code{run(comand = '{"ping: 1}')}}{Change the name or database of a collection. Changing name is cheap, changing database is expensive.}
#'   \item{\code{replace(query, update = '{}', upsert = FALSE)}}{Replace matching record(s) with value of the \code{update} argument.}
#'   \item{\code{update(query, update = '{"$set":{}}', upsert = FALSE, multiple = FALSE)}}{Modify fields of matching record(s) with value of the \code{update} argument.}
#'   \item{\code{use(collection, db)}}{Creates a [mongo] object representing a collection in a database, using the active connection}#'
#' }
mongo <- function(collection = "test", db = "test", url = "mongodb://localhost", verbose = FALSE, options = ssl_options()){
  mongoclient <- mongo_client(url, verbose, options)

  actual_db <-
    if(missing(db) || is.null(db)){
      url_db <- mongoclient$default_database()
      if(length(url_db) && nchar(url_db))
        db <- url_db
    } else db

  mongoclient$use(collection, actual_db)
}

mongo_object <- function(col_, mongo_client, db_name, collection_name, verbose, orig){

  col <- col_

  renewColl <- function() {
    col <<- parent.env(mongo_client)$check_col(col, collection_name, db_name, orig)
  }

  # The reference object
  self <- local({
    use <- function(collection, db = db_name){
      renewColl()
      mongo_client$use(collection, db)
    }

    insert <- function(data, pagesize = 1000, stop_on_error = TRUE, ...){
      renewColl()
      if(is.data.frame(data)){
        mongo_stream_out(data, col, pagesize = pagesize, verbose = verbose, stop_on_error = stop_on_error, ...)
      } else if(is.list(data) && !is.null(names(data))){
        mongo_collection_insert_page(col, mongo_to_json(data, ...), stop_on_error = stop_on_error)
      } else if(is.character(data)) {
        if(!all(is_valid <- vapply(data, jsonlite::validate, logical(1), USE.NAMES = FALSE))){
          el <- paste(which(!is_valid), collapse = ", ")
          stop("Argument 'data' is a character vector but contains invalid JSON at elements: ", el)
        }
        if(!all(is_valid <- grepl("^\\s*\\{", data))){
          el <- paste(which(!is_valid), collapse = ", ")
          stop("Argument 'data' contains strings that are not JSON objects at elements: ", el)
        }
        mongo_collection_insert_page(col, data, stop_on_error = stop_on_error)
      } else if(inherits(data, "bson")){
        mongo_collection_insert_bson(col, data, stop_on_error = stop_on_error)
      } else {
        stop("Argument 'data' must be a data frame, named list, or character vector with json strings")
      }
    }

    find <- function(query = '{}', fields = '{"_id":0}', sort = '{}', skip = 0, limit = 0, handler = NULL, pagesize = 1000){
      renewColl()
      cur <- mongo_collection_find(col, query = query, sort = sort, fields = fields, skip = skip, limit = limit)
      mongo_stream_in(cur, handler = handler, pagesize = pagesize, verbose = verbose)
    }

    iterate <- function(query = '{}', fields = '{"_id":0}', sort = '{}', skip = 0, limit = 0) {
      renewColl()
      cur <- mongo_collection_find(col, query = query, sort = sort, fields = fields, skip = skip, limit = limit)
      # make sure 'col' does not go out of scope to prevent gc
      mongo_iterator(cur, col)
    }

    export <- function(con = stdout(), bson = FALSE){
      renewColl()
      if(isTRUE(bson)){
        mongo_dump(col, con, verbose = verbose)
      } else {
        mongo_export(col, con, verbose = verbose)
      }
    }

    import <- function(con, bson = FALSE){
      renewColl()
      if(isTRUE(bson)){
        mongo_restore(col, con, verbose = verbose)
      } else {
        mongo_import(col, con, verbose = verbose)
      }
    }

    aggregate <- function(pipeline = '{}', options = '{"allowDiskUse":true}', handler = NULL, pagesize = 1000){
      renewColl()
      cur <- mongo_collection_aggregate(col, pipeline, options)
      mongo_stream_in(cur, handler = handler, pagesize = pagesize, verbose = verbose)
    }

    count <- function(query = '{}'){
      renewColl()
      mongo_collection_count(col, query)
    }

    remove <- function(query, just_one = FALSE){
      renewColl()
      invisible(mongo_collection_remove(col, query, just_one))
    }

    drop <- function(){
      renewColl()
      invisible(mongo_collection_drop(col))
    }

    update <- function(query, update = '{"$set":{}}', filters = NULL, upsert = FALSE, multiple = FALSE){
      renewColl()
      mongo_collection_update(col, query, update, filters, upsert, multiple = multiple, replace = FALSE)
    }

    replace <- function(query, update = '{}', upsert = FALSE){
      renewColl()
      mongo_collection_update(col, query, update, upsert = upsert, replace = TRUE)
    }

    mapreduce <- function(map, reduce, query = '{}', sort = '{}', limit = 0, out = NULL, scope = NULL){
      renewColl()
      cur <- mongo_collection_mapreduce(col, map = map, reduce = reduce, query = query,
        sort = sort, limit = limit, out = out, scope = scope)
      results <- mongo_stream_in(cur, verbose = FALSE)
      if(is.null(out))
        results[[1, "results"]]
      else
        results
    }

    distinct <- function(key, query = '{}'){
      renewColl()
      out <- mongo_collection_distinct(col, key, query)
      jsonlite:::simplify(out$values)
    }

    info <- function(){
      renewColl()
      list(
        name = mongo_collection_name(col),
        stats = tryCatch(mongo_collection_stats(col), error = function(e) NULL),
        server = mongo_client$server_status()
      )
    }

    rename <- function(name, db = NULL){
      renewColl()
      out <- mongo_collection_rename(col, db, name)
      orig <<- list(
        name =  tryCatch(mongo_collection_name(col), error = function(e){name}),
        db = ifelse(is.null(db), db_name, db),
        url = orig$url
      )
      orig
    }

    run <- function(command = '{"ping: 1}'){
      renewColl()
      mongo_collection_command_simple(col, command)
    }

    index <- function(add = NULL, remove = NULL){
      renewColl()
      if(length(add))
        mongo_collection_create_index(col, add);

      if(length(remove))
        mongo_collection_drop_index(col, remove);

      mongo_collection_find_indexes(col)
    }
    environment()
  })
  lockEnvironment(self, TRUE)
  structure(self, class=c("mongo", "jeroen", class(self)))
}

#' @export
print.mongo <- function(x, ...){
  if( exists('mongo_client', parent.env(x)) ) {
    parent.env(x)$renewColl()
  } else {
    print('type')
    print(typeof(x))
    print('attr')
    print(ls(x))
    print('pattr')
    print(ls(parent.env(x)))
    print('pattr2')
    print(ls(parent.env(parent.env(x))))
    parent.env(x)$renewColl()
  }
  print.jeroen(x, title = paste0("<Mongo collection> '", mongo_collection_name(parent.env(x)$col), "'"))
}

#' @export
print.miniprint <- function(x, ...){
  utils::str(unclass(x))
  invisible(x)
}

#setGeneric("serialize")
#setOldClass("jeroen")
#setMethod("serialize", "jeroen", function(object, connection){
#  if(!missing(connection)) {
#    writeBin(bson_to_raw(object), connection)
#  } else {
#    bson_to_raw(object);
#  }
#});
