#All the following functions calculate sigma2^1.5 * component
#(later we will multipy by sigma2^-1.5 to get the right value)
#this is done because we need W for the SE calculations

between.skew <- function(ss){
  #extract sample level statistics
  mu <- ss$mu1[1]
  W <- with(ss, sum(p_g * mu_g^3) - 3*mu*sum(p_g * mu_g^2) +2*mu^3)
  return(W)
}

within.skew <- function(ss){
  W <- with(ss, sum(p_g * (mu3_g - 3*mu_g*sigma2_g - mu_g^3)))
  return(W)
}

cov.skew <- function(ss){
  #extract sample level statistics
  mu <- ss$mu1[1]
  w1 <- with(ss, sum(p_g * (mu2_g*mu_g - mu_g^3)))
  w2 <- with(ss, sum(p_g * (mu_g^2 - mu2_g)))
  W <- w1 + mu*w2
  return(W)
}

var_between.skew <- function(ss, W){
  #extract sample level statistics
  mu <- ss$mu1[1]
  sigma <- sqrt(ss$sigma2[1])
  sum_p_i2 <- ss$sum_p_i2[1]
  tmp <- with(ss, 3*p_g*mu_g^2 + p_g*6*mu^2 -3*(p_g*sum(p_g*mu_g^2) + 2*mu*mu_g*p_g))
  A_g <- with(ss, 3*mu*W*p_g / sigma^5 + tmp / sigma^3)
  B_g <- with(ss, -1.5*p_g*W / sigma^5)
  tmp <- with(ss, mu_g^3 + mu_g*6*mu^2  - 3*(mu_g*sum(p_g*mu_g^2) + mu*mu_g^2))
  C_g <- with(ss, -1.5*W*(mu2_g - 2*mu*mu_g) / sigma^5 + tmp / sigma^3)
  res <- with(ss, sum(var_mu_g * A_g^2 + var_mu2_g * B_g^2))
  res <- res + calc_p_term(p = ss$p_g, const = C_g, sum_p_i2)
  res <- res + 2* sum (A_g * B_g * ss$cov_mu_g_mu2_g)
  return(res)
}

var_within.skew <- function(ss, W){
  #extract sample level statistics
  mu <- ss$mu1[1]
  sigma <- sqrt(ss$sigma2[1])
  sum_p_i2 <- ss$sum_p_i2[1]
  tmp <- with(ss, p_g*(-3*mu_g^2 - 3*(mu2_g - 3*mu_g^2)))
  A_g <- with(ss, 3*mu*p_g*W/sigma^5 + tmp*sigma^-3)
  B_g <- with(ss, -1.5*p_g*W/sigma^5 - 3*mu_g*p_g/sigma^3)
  C_g <- with(ss, p_g/sigma^3)
  tmp <- with(ss, mu3_g-3*mu_g*sigma2_g-mu_g^3)
  D_g <- with(ss, -1.5*(mu2_g - 2*mu*mu_g)*W / sigma^5 + tmp*sigma^-3)
  res <- with(ss, sum(var_mu_g * A_g^2 + var_mu2_g * B_g^2 + var_mu3_g * C_g^2))
  res <- res + calc_p_term(p = ss$p_g, const = D_g, sum_p_i2)
  res <- res + 2* sum (A_g * B_g * ss$cov_mu_g_mu2_g)
  res <- res + 2* sum (A_g * C_g * ss$cov_mu_g_mu3_g)
  res <- res + 2* sum (B_g * C_g * ss$cov_mu2_g_mu3_g)
  return(res)
}

var_cov.skew <- function(ss, W){
  #extract sample level statistics
  mu <- ss$mu1[1]
  sigma <- sqrt(ss$sigma2[1])
  sum_p_i2 <- ss$sum_p_i2[1]
  tmp <- with(ss, p_g*(mu2_g - 3*mu_g^2) + p_g*sum(p_g*(mu_g^2-mu2_g)) + 2*mu*mu_g*p_g)
  A_g <- with(ss, 3*mu*W*p_g / sigma^5 + tmp / sigma^3)
  tmp <- with(ss, p_g*mu_g - mu*p_g)
  B_g <- with(ss, -1.5*p_g*W / sigma^5 + tmp*sigma^-3)
  tmp <- with(ss, mu2_g*mu_g - mu_g^3)
  tmp <- tmp + with(ss, mu_g*sum(p_g*(mu_g^2 - mu2_g)) + mu*(mu_g^2-mu2_g))
  C_g <- with(ss, -1.5*(mu2_g - 2*mu*mu_g)*W/sigma^5 + tmp*sigma^-3)
  res <- with(ss, sum(var_mu_g * A_g^2 + var_mu2_g * B_g^2))
  res <- res + calc_p_term(p = ss$p_g, const = C_g, sum_p_i2)
  res <- res + 2* sum (A_g * B_g * ss$cov_mu_g_mu2_g)
  return(res)
}

skew_decomp <- function(y, x, wgt = rep(1, length(y))){
  S <- suf_stat(y, x, wgt)
  sigma2 <- wtd_var(y, wgt)
  between <- between.skew(S)
  between_se <- sqrt(var_between.skew(S, between))
  between <- between * sigma2^-1.5
  within <- within.skew(S)
  within_se <- sqrt(var_within.skew(S, within))
  within <- within * sigma2^-1.5
  cov <- cov.skew(S)
  cov_se <- 3*sqrt(var_cov.skew(S, cov))
  cov <- 3*cov * sigma2^-1.5
  res <- c(between, within, cov, between_se,
           within_se, cov_se = cov_se)
  names(res) <- c("between", "within", "3COV", "between_se",
                  "within_se", "3COV_se")
  return(res)
}

#' Weighted Skewness
#' 
#' computes weighted version of the skewness estimator.
#' 
#' @param x a numeric vector
#' @param wgt an optional vector of weights.
#' @return scalar
#' @importFrom Hmisc wtd.mean
#' @export
wtd_skew <- function(x, wgt = rep(1, length(x))){
  x <- (x - wtd.mean(x, wgt)) / sqrt(wtd_var(x, wgt))
  wtd.mean(x^3, wgt)
}
















