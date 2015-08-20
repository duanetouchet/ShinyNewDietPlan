library(shiny)


# Initialize data 
myData <- as.data.frame(matrix(ncol=6,nrow=1))
colnames(myData) <- c("Week","CaloriesBurnedPerDay","CalorieDeficitPerDay", "CaloriesToConsumePerDay","PredictedWeight","PredictedBMI")

# BMI categories
bmiHealthy <- 18
bmiOverweight <- 25 
bmiObese <- 31
bmiExtremelyObese <- 40 

# Functions to get data
getHeight <- function(feet, inches) ( feet * 12 ) + inches

getBMI <- function(weight, height) round(703 * ( weight / height^2 ),1)

getBMR <- function(gender, weight, height, age) {
     # Male calories
     if ( gender == 1 ) {
          BMR <- 66 + ( 6.23 * weight ) + ( 12.7 * height ) - ( 6.8 * age )
     } else {
     # Female calories
          BMR <- 655 + ( 4.35 * weight ) + ( 4.7 * height ) - ( 4.7 * age )
     }   
     BMR
}

getAvgPoundsWeek <- function(curWeight, tarWeight, numWeeks) round((curWeight - tarWeight) / numWeeks,2)

getActivityFactor <- function(activity) {
     if ( activity == "sedentary" ) {
          actlevel <- 1.2
     } else if ( activity == "light") {
          actlevel <- 1.375
     } else if ( activity == "moderate") {
          actlevel <- 1.55
     } else if ( activity == "heavy") {
          actlevel <- 1.725
     } else {
          actlevel <- 1.9
     }
     actlevel     
}

getAvgCalBurnDay <- function(bmr,activity) {
     actlevel <- getActivityFactor(activity)
     round(bmr * actlevel)
}

getAvgCalDeficit <- function(avgPoundPerWeek) round(avgPoundPerWeek * 500 )

getAvgCalToConsume <- function(burned, deficit) burned - deficit 

getPlots <- function(curWeight, tarWeight, height, age, activity, numweeks, gender) {
          
     # Create data frames for Plots
     preBMI <- getBMI(curWeight, height)
     preWeight <- curWeight
     preBMR <- getBMR(gender, preWeight, height,age)
     avgPoundsWeek <- getAvgPoundsWeek(curWeight, tarWeight, numweeks)
     avgBurn <- getAvgCalBurnDay(preBMR, activity)
     avgDef <- getAvgCalDeficit(avgPoundsWeek)
     preCal <- getAvgCalToConsume(avgBurn, avgDef)
     
     for (n in 0:numweeks+1) {
          # Figure BMI and calories
          preBMI <- getBMI(preWeight,height)          

          # Recompute calories needed this week
          if ( gender == 1 ) {
               # Male calories
               preBMR <- 66 + ( 6.23 * preWeight ) + ( 12.7 * height ) - ( 6.8 * age )
          } else {
               # Female calories
               preBMR <- 655 + ( 4.35 * preWeight ) + ( 4.7 * height ) - ( 4.7 * age )
          }
          
          preCalBurn <- preBMR * getActivityFactor(activity)
          preCalDef <- getAvgCalDeficit(avgPoundsWeek)
          preCal <- preCalBurn - preCalDef
          
          # Insert into frames data for that week
          if ( n == 0 ) {
               myData <- c(n,preCalBurn,preCalDef,preCal,preWeight,preBMI)
          } else {
               myData <- rbind(myData,c(n,preCalBurn,preCalDef,preCal,preWeight,preBMI))
          }

          # At end of each week, predict the next week's data
          preWeight = preWeight - avgPoundsWeek

     }
     
     myData <- myData[-1,]
     
     data.frame(myData)
}

# Define server logic
shinyServer(
     function(input, output) {

     # Gather data in data frame for plotting
     newData <- reactive(
          getPlots(input$curWeightPounds, input$targetWeightPounds, 
                   getHeight(input$curHeightFeet,input$curHeightInches), 
                   input$curAge, input$lvlActivity, input$numWeeksToAchieve, input$radioGender
          )
     )          
          
     # Output current state
     output$currentState <- renderText({
          paste(
               "Current BMI:",
               getBMI(input$curWeightPounds, getHeight(input$curHeightFeet, input$curHeightInches)),
               "....",
               "Target BMI:",
               getBMI(input$targetWeightPounds, getHeight(input$curHeightFeet, input$curHeightInches)),
               "....",
               "Total Pounds to Lose:",
               input$curWeightPounds - input$targetWeightPounds
                )
     })

     # Output predictive weekly/daily average data
     output$averageData <- renderText({
          paste(
               "Avg # Pounds to Lose/Week:",
               getAvgPoundsWeek(input$curWeightPounds, input$targetWeightPounds, input$numWeeksToAchieve ),
               "......",
               "Average Calories per Day ->",
               " Burned:",
               round(mean(newData()$CaloriesBurnedPerDay)),
               "...",
               " Deficit Needed:",
               round(mean(newData()$CalorieDeficitPerDay)),
               "...",
               " Consumed:",
               round(mean(newData()$CaloriesToConsumePerDay))
          )
     })
     

     # Output plots
     
     output$calPlot <- renderPlot({ 
          plot(CaloriesToConsumePerDay~Week, ylab="Calories to Consume per Day", xlab="Week #",
               main="Calories to Consume per Day", type="line", lwd=5, data = newData()
           )
          grid(lwd=2, col="lightgray",lty="dotted")
          })
     
     output$weightPlot <- renderPlot({ plot(PredictedWeight~Week, ylab="Weight", xlab="Week #",
               main="Weight per Week", type="line", lwd=5, data = newData()
          )
          grid(lwd=2, col="lightgray",lty="dotted")
          })
     
     output$bmiPlot <- renderPlot({ 
          plot(PredictedBMI~Week, ylab="BMI", xlab="Week #", 
               main="BMI per Week", type="line", lwd=5, data = newData()
           )
          grid(lwd=2, col="lightgray",lty="dotted")
          
          abline(h=bmiHealthy-.15, lwd=6, col="lightblue")
          
          abline(h=bmiHealthy, lwd=6, col="green3")
          abline(h=bmiOverweight-.15, lwd=6, col="green3")
          text(10, (bmiHealthy+bmiOverweight)/2, "Healthy", cex=2, col="green3")
          
          abline(h=bmiOverweight, lwd=6, col="yellow3")
          abline(h=bmiObese-.15, lwd=6, col="yellow3")
          text(10, (bmiOverweight+bmiObese)/2, "Overweight", cex=2, col="yellow3")
          
          abline(h=bmiObese, lwd=6, col="orange3")
          abline(h=bmiExtremelyObese-.15, lwd=6, col="orange3")
          text(10, (bmiObese+bmiExtremelyObese)/2, "Obese", cex=2, col="orange3")
          
          abline(h=bmiExtremelyObese, lwd=6, col="red3")
          text(10, bmiExtremelyObese+5, "Extremely Obese", cex=2, col="red3")
      })
     
     output$myTable <- renderTable({ newData() }, include.rownames=FALSE)
})
