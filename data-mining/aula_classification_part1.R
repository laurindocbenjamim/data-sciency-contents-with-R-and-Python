





fatds_indices <- createFacts(data$RISK, k=10)
accuracy <- c()

for(i in 1:10){
  trainset <- data[-fatds_indices[[i]]]
  testset <- data[fatds_indices[[i]],]
  
  model <- glm(RISK ~., trainset[,-1], family = binomial("logit"))
  
  pred_probs <- predict(model, testset[,-1], type="response")
  
  predict_classes <- ifelse(pred_probs >= 0.5, 1, 0)
  accuracy[i] <- sum(predict_classes==testset$RISK)/nrow(testset)
}