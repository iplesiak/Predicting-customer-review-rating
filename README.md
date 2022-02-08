# Predicting-customer-review-rating
Comparing prediction power of NLP-based model vs Product attribute-based model by means of supervised machine learning methods(GLM, KNN, Random forest, and LightGBM)

Sub questions:
Which variables have the biggest impact on the customer satisfaction score, and can these variables be used as a tool to accurately predict customer satisfaction scores?
Can distinguishable topics be extracted from customer reviews using the NLP method?
Does a supervised machine learning approach based on NLP analysis is better in predicting customer satisfaction scores than more conventional variables (price, delivery time, information quality, etc.)?
Would a combination of a supervised machine learning model based on NLP analysis with a more conventional machine learning model based on variables of interest improve the prediction power?


To conclude, both NLP and product attribute-based models were able to predict customer satisfaction score (both dimensionalities - multiclass and binary) 
with surprising accuracy. Moreover, NLP has achieved a slightly superior F1 scores for both dimensionalities - multiclass (F1 - 0.7444788) and binary 
(F1 - 0.8770341), therefore one can infer that customer reviews are more useful when it comes to predicting customer satisfaction level. However, 
combining two methods (NLP and product attribute-based) through ensembling technique improves the prediction power dramatically. Therefore, it can be 
concluded that in order to achieve the utmost prediction accuracy it is best to combine both methods together or build one model which would incorporate 
both - the most frequently appearing words and product and service related attributes. It is important to mention that balancing the dataset reduces the 
ability of supervised machine learning methods to find latent data structure, resulting in worse prediction accuracy.
With regards to the most impactful variable, delivery_diff appeared to be the most important one, which makes sense as it reflects whether the product 
was delivered to the end customer faster or slower than he/she had expected. Furthermore, it is one of the few ways the company can add additional perceived 
value to the customer purchase experience. The second and third variables having the biggest impact on predicting the dependent variable were freight_value 
and product_description_length. Looking at the most frequently appearing words one can conclude that in general, customers are satisfied with the service as 
they receive the product faster than expected, and are even willing to recommend the service and/or product to others.

Managerial Implications:
Results of the present study suggest that supervised machine learning methods can be used as a tool to predict customer satisfaction score, as in both cases 
of dimensionality (multiclass and binary) they provided with quite high prediction power. Moreover, NLP analysis and the Random Forest algorithm indicated 
that delivery is the most important feature out of all, where faster than expected delivery is perceived extremely positively by the customers and adds 
additional value to the customer experience as an end result. Therefore it can be suggested to optimize that feature of service and if possible improve 
the delivery speed, however, without raising the expectation of the customer, so that the effect would not be flattened.
Furthermore, managers are advised to pay more attention to the quality of the information provided in the description of the product, as it appears highly 
important to the customers, which corresponds to the research conducted by Liu, He, Gao and Xie (2009). Combining both would most likely result in enhancing 
customer satisfaction, however an additional push is needed for customers to leave a positive review. Therefore, managers can be suggested an email campaign 
targeting those customers whose products arrived earlier than expected. It is especially valuable for newly introduced products, because the conversion rate 
of a product increases by around 270% as it starts to accumulate the reviews (Askalidis and Malthouse, 2016). For that reason, in case of late delivery, customers 
should be informed beforehand and offered an alternative or the solution to the problem to enhance the customer experience, thus minimizing the number of negative reviews.
