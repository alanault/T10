# server.R

# Code for T10 buzz analysis chart Shiny App
# Aim is for simple interface to let us plot weekly and cummulative buzz and intent
# Across a database of movies
# Simply update the database and voila, you can plot to your hearts content
# Uses GGVis so easy to download SVG version
# You can also select multiple movies for comparison

# First, load required packages
library (BH)
library (dplyr)

# We load dataset here as well as UI as they run independantly.
# Without it, we can't generate charts
# Load in the t10 dataset
t10 <- readRDS ("./data/t10.rds")

# Main shiny function
shinyServer(function(input, output) {
  
  # Output text to tell us what movies and metric we picked
  output$text1 <- renderText ({input$movie})
  output$text2 <- renderText ({input$metric})
  
  # Add tooltip function for hover-over
  movie_tooltip <- function (x) {
    # Check for null
    if (is.null (x)) return (NULL)
    # Create a name with all the outputs
    paste0 (names (x), ": ", format(x), collapse="<br>")
  }


  # We need a reactive output to create a new, subset of our data
  # once the user has clicked on the movies they want to select
  # We also need to drop the factor levels for the movie, otherwise
  # We get all of them listed, whether we plot or not
  dat <- reactive({
           t10 %>%
            filter  (Title %in% input$movie) %>%
           droplevels ()
            })

  # Reactive output for creating a ggvis chart
  # Nice plotting library!
  # Creates the object, once it detects that an input has change
  vis <- reactive ({

    # Need to make metric somthing we can plot
    # as currently, it'll be seen as character string
    metric <- prop ("y", as.symbol (input$metric))
    
    # now we do the main plotting options
    g <- dat %>%
      ggvis ( ~Week,  y= metric, stroke= ~Title) %>%
      layer_lines()  %>%
      set_options (resizable=TRUE) %>%
      add_tooltip (movie_tooltip, "hover") %>%
      add_axis ("x", title="t-(n) weeks before launch",
                properties=axis_props(labels=list(fontSize=10),
                                      title=list(fontSize=12))) %>%
      add_axis ("y", title=as.character(metric), 
                properties=axis_props(labels=list(fontSize=10), 
                                      title=list(fontSize=12, dy=-30))) %>%
      add_legend (scales = "stroke", properties = legend_props (
                                                    legend = list(y = 20, x=20),
                                                  labels=list(fontSize=12),
                                                  title=list(fontSize=12))) %>%
      set_options(duration = 0)
    
    # finally, plot the object itself
    g
  })
  
  # Now we can bind out object onto the output list as our plot
  vis %>% bind_shiny ("plot")

})


