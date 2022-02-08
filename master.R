customers <- read.csv("./olist_customers_dataset.csv")
order_items <- read.csv("./olist_order_items_dataset.csv")
payments <- read.csv("./olist_order_payments_dataset.csv")
reviews <- read.csv("./olist_order_reviews_dataset.csv")
orders <- read.csv("./olist_orders_dataset.csv")
products <- read.csv("./olist_products_dataset.csv")
sellers <- read.csv("./olist_sellers_dataset.csv")
category_translation <- read.csv("./product_category_name_translation.csv")


master <- merge(customers, orders, by.x = "customer_id", by.y = "customer_id")
master <- merge(master, reviews, by.x = "order_id", by.y = "order_id")
master <- merge(master, order_items, by.x = "order_id", by.y = "order_id")
master <- merge(master, sellers, by.x = "seller_id", by.y = "seller_id")
master <- merge(master, products, by.x = "product_id", by.y = "product_id")
master <- merge(master, category_translation, by.x = "product_category_name", by.y = "product_category_name")
master <- merge(master, payments, by.x = "order_id", by.y = "order_id")

View(master)
summary(master)

#checking for missings--------------------------------------------------
colSums(is.na(master))
install.packages("visdat")
library(visdat)

vis_miss(master, warn_large_data = FALSE)
#less than 0,1% missings (way less than 5% missings rule) for variables which we won't even use for future analysis, but to be sure, let's delete it
master1 <- na.omit(master)
colSums(is.na(master1)) #no missings


#changing variables to the right format---------------------------------
str(master1)
master1$order_status <- as.factor(master1$order_status)
master1$order_purchase_timestamp <- as.Date(paste(master1$order_purchase_timestamp, sep=""))
master1$order_approved_at <- as.Date(paste(master1$order_approved_at, sep=""))
master1$order_delivered_carrier_date <- as.Date(paste(master1$order_delivered_carrier_date, sep=""))
master1$order_delivered_customer_date <- as.Date(paste(master1$order_delivered_customer_date, sep=""))
master1$order_estimated_delivery_date <- as.Date(paste(master1$order_estimated_delivery_date, sep=""))
master1$shipping_limit_date <- as.Date(paste(master1$shipping_limit_date, sep=""))
master1$product_category_name_english <- as.factor(master1$product_category_name_english)
master1$payment_type <- as.factor(master1$payment_type)
master1$review_score <- as.factor(master1$review_score)
master1$customer_state <- as.factor(master1$customer_state)
master1$seller_state <- as.factor(master1$seller_state)
master1$product_name_lenght <- as.numeric(master1$product_name_lenght)

#creating new variables delivery time + difference between expected delivery and actual delivery
master1$delivery_days <- master1$order_delivered_customer_date - master1$order_approved_at
master1$delivery_days <- as.numeric(master1$delivery_days)

master1$delivery_diff <- master1$order_delivered_customer_date - master1$order_estimated_delivery_date
master1$delivery_diff <- as.numeric(master1$delivery_diff)

colSums(is.na(master1))#missings are for products with canceled status
master2 <- na.omit(master1)

#saving dataset
getwd()
setwd("/Users/plesiaq/Desktop/Marketing Masters/Thesis/DATA/")
write.csv(master2, file="master2.csv")

master2 <-read.csv("~/Desktop/Marketing Masters/Thesis/DATA/master2.csv")


#checking for outliers--------------------------------------------------
#building some plots

#plots

master2 %>%
  ggplot(aes(x = 1, y = order_item_id)) +
  geom_boxplot()

master2 %>%
  ggplot(aes(x = 1, y = price)) +
  geom_boxplot()

master2 %>%
  ggplot(aes(x = 1, y = freight_value)) +
  geom_boxplot()

master2 %>%
  ggplot(aes(x = 1, y = product_name_lenght)) +
  geom_boxplot()


master2 %>%
  ggplot(aes(x = 1, y = product_description_lenght)) +
  geom_boxplot()

master2 %>%
  ggplot(aes(x = 1, y = product_photos_qty)) +
  geom_boxplot()


master2 %>%
  ggplot(aes(x = 1, y = payment_value)) +
  geom_boxplot()

str(master2)

#Let's apply some outliers tests (only for numeric/int)
Modout <- lm(review_score ~  order_item_id + price + freight_value + product_name_lenght + product_description_lenght + product_photos_qty + payment_value, data=master2)
car::outlierTest(Modout)

#let's check cooks distance
cooksdist <- cooks.distance(Modout)

# plotting outliets based on cooks distance
plot(cooksdist, pch="*", cex=2, main="Influential Obs by Cooks distance BEFORE")  # plot cook's distance
abline(h = 4*mean(cooksdist, na.rm=T), col="red")  # add cutoff line
text(x=1:length(cooksdist)+1, y=cooksdist, labels=ifelse(cooksdist>4*mean(cooksdist, na.rm=T),names(cooksdist),""), col="red")  # add labels

#seeing some outliers, let's deep dive and see which are the most influential
influential <- as.numeric(names(cooksdist)[(cooksdist > 4*mean(cooksdist, na.rm=T))])  # influential row numbers
head(master1[influential, ])
master1[influential, ] #there are some influential rows.

#however, it doesn't make sense to delete outliers in our case as they are part of the reality therefore we apply winsorization technique to deal with them
#variables of interest price/freight_value/payment_value

install.packages("DescTools")
library(DescTools)
master3 <- master2

master3$price<- Winsorize(master2$price, probs = c(0.05, 0.95))
master3$freight_value<- Winsorize(master2$freight_value, probs = c(0.05, 0.95))
master3$payment_value<- Winsorize(master2$payment_value, probs = c(0.05, 0.95))

str(master3)

###multicollinearity check
multitest <- lm(review_score ~  customer_zip_code_prefix + customer_state +
                  order_item_id + price + freight_value + seller_zip_code_prefix + seller_state
                +product_name_lenght + product_description_lenght + product_photos_qty + delivery_days + delivery_diff, data=master3) 
#create vector of VIF values and a vector of tolerance values
vif_values <- vif(multitest)
tolerance <- 1/vif_values
# the closer to 1, the lower the level of multicollinearity. Result - customer_zip_code_prefix and seller_zip_code_prefix has multicollinearity with review score.
vif_values
#The closer to 0, the higher the level of multicollinearity. Result - customer_zip_code_prefix and seller_zip_code_prefix has multicollinearity with review score.
tolerance
#customer_zip_code_prefix and seller_zip_code_prefix has multicollinearity with review score.
#let's try to leave out these two variables 
summary(multitest)

multitest1 <- lm(review_score ~ customer_state +
                  order_item_id + price + freight_value + seller_state
                +product_name_lenght + product_description_lenght + product_photos_qty + delivery_days + delivery_diff, data=master3) 

#create vector of VIF values and a vector of tolerance values
vif_values1 <- vif(multitest1)
tolerance1 <- 1/vif_values1
# the closer to 1, the lower the level of multicollinearity. Result - no multicollinearity
vif_values1
#The closer to 0, the higher the level of multicollinearity. Result - no multicollinearity
tolerance1

#no mullticollinearity, and the model still explains a lot - we can continue
summary(multitest1)

#Generalized Linear Model for product/service attributes
#splitting data on testing and validation datasets
master3$estimation_sample <-rbinom(nrow(master3), 1, 0.75)
estimation_sample <- master3[master3$estimation_sample==1,]
validation_dataset <- master3[master3$estimation_sample==0,]
estimation_sample$review_score <- as.factor(estimation_sample$review_score)
validation_dataset$review_score <- as.factor(validation_dataset$review_score)

getwd()
write.csv(master3, file="master3.csv")
write.csv(validation_dataset, file="validation_dataset.csv")
str(master3)

View(estimation_sample)
str(estimation_sample$review_score)

FirstGLM <- lm(review_score ~ price + freight_value + product_name_lenght + product_description_lenght + product_photos_qty + delivery_diff, data = estimation_sample)

#Get predictions for all observations for validation sample
predictions_model2 <- predict(FirstGLM, newdata= validation_dataset, type = "response")
predictions_model2

#trying some stuff
install.packages("MASS")
library(MASS)
remove.packages("dplyr")
polrMod <- polr(review_score ~ price + freight_value + product_name_lenght + product_description_lenght + product_photos_qty + delivery_diff, data = estimation_sample)
summary(polrMod)

predictedClass <- predict(polrMod, validation_dataset)  # predict the classes directly
head(predictedClass)

predictedScores <- predict(polrMod, validation_dataset, type="p")  # predict the probabilites
head(predictedScores)

table(validation_dataset$review_score, predictedClass)

mean(as.character(validation_dataset$review_score) != as.character(predictedClass))

### After this you can calculate the fit criteria on this validation sample
# Fit criteria ------------------------------------------------------------

#Make the basis for the hit rate table
predicted_model2 <- ifelse(predictions_model2>.5,1,0)

hit_rate_model2 <- table(our_validation_dataset$survived, predicted_model2, dnn= c("Observed", "Predicted"))

hit_rate_model2

#Get the hit rate
(hit_rate_model2[1,1]+hit_rate_model2[2,2])/sum(hit_rate_model2)


#Top decile lift
library(dplyr) 

decile_predicted_model2 <- ntile(predictions_model2, 10)

decile_model2 <- table(validation_dataset$review_score, decile_predicted_model2, dnn= c("Observed", "Decile"))

decile_model2

#Calculate the TDL
(decile_model2[2,10] / (decile_model2[1,10]+ decile_model2[2,10])) / mean(validation_dataset$review_score)


#Make lift curve
install.packages("ROCR")
library(ROCR)

pred_model2 <- prediction(predictions_model2, validation_dataset$review_score)
perf_model2 <- performance(pred_model2,"tpr","fpr")
plot(perf_model2,xlab="Cumulative % of observations",ylab="Cumulative % of positive cases",xlim=c(0,1),ylim=c(0,1),xaxs="i",yaxs="i")
abline(0,1, col="red")
auc_model2 <- performance(pred_model2,"auc")

#The Gini is related to the "Area under the Curve" (AUC), namely by: Gini = AUC*2 - 1
#So to get the Gini we do:
as.numeric(auc_model2@y.values)*2-1


