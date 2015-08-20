# Define UI for shiny application
shinyUI(fluidPage(
     # Application title
     titlePanel("Shiny New Diet Plan"),
     
     # Sidebar with inputs
     sidebarLayout(
          sidebarPanel(
               
               sliderInput("curHeightFeet",
                            "Current Height - Feet:",
                            min=4, 
                            max=7,
                            value=5
                            ),
               
               sliderInput("curHeightInches",
                            "Current Height - Inches:",
                            min = 0,
                            max = 11,
                            value = 0
                            ),
               
               sliderInput("curWeightPounds",
                            "Current Weight - Pounds:",
                            min=50,
                            max=400,
                            value=150
                            ),
               
               sliderInput("curAge",
                            "Current Age - Years:",
                            min=1,
                            max=80,
                            value=30
                            ),
               
               sliderInput("targetWeightPounds",
                            "Target Weight - Pounds:",
                            min=50,
                            max=400,
                            value=150
                            ),
               
               sliderInput("numWeeksToAchieve",
                            "Number of Weeks to Diet: ",
                            min=1,
                            max=156,
                            value=6
                            ),
               
               selectInput("lvlActivity",
                           "Activity Level: ",
                           choices = list("Sedentary" = "sedentary",
                                          "Light exercise (30-50 minutes, 3-4 days/week, leisure walking/golfing/housework)" = "light",
                                          "Moderate exercise (30-60 minutes, 3-5 days/week, 60-70% max heartrate)" = "moderate",
                                          "Heavy exercise (45-60 minutes, 6-7 days/week, 70-85% max heartrate)" = "heavy",
                                          "Extreme exercise (90+ minutes, 6-7 days/week, intense workouts)" = "extreme"
                           )
                           
               ),
               
               radioButtons("radioGender",
                            "Gender: ",
                            choices = list("Male" = 1, "Female" = 0),
                            select = 1),
   
               submitButton("Calculate Diet Plan")
          ),
          
          # Main panel, plots and data
          mainPanel(
               
               HTML("Many diet calculators compute calorie deficit needed based only on your current proportions. This is a problem because the number of calories you normally burn will change over time as your weight changes. A better plan is to re-calculate the required calorie deficit needed periodically so that the weight loss doesn't plateau before the target weight has been obtained. This app does that calculation for you.<br/><br/>"),
               HTML("<b>NOTE: <i>Before starting any diet plan, it is advisable to consult your health care professional!</i></b><br/>"),
               HTML("<i><br/>BMI = Body mass index, a number that categorizes a person into underweight, healthy, overweight, obese, and extremely obese categories. BMI has a flaw in that it does not account for muscle-to-fat ratio so use BMI as a general rule only.</i><br/><br/>"),
               
               htmlOutput("statusText"),
               
               textOutput("currentState"),
               textOutput("averageData"),

               plotOutput("calPlot"),
               
               plotOutput("bmiPlot"),
               
               plotOutput("weightPlot"),
               
               HTML("<b><big>Calculated Data</big></b><br/>"),
               
               tableOutput("myTable"),
               
               HTML("<b><i>DISCLAIMER: This data is for entertainment purposes only. Please diet responsibly and contact a health professional first!</i></b><br/><br/>")

          )
     )

))