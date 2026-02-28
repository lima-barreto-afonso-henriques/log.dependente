#' Previsão Corrigida para Modelos com Variável Dependente em Log
#'
#' Esta função implementa os procedimentos de correção de viés de Wooldridge
#' para modelos de regressão linear onde a variável dependente está em logaritmo.
#'
#' @param modelo_log Um objeto de classe \code{lm} estimado com log(y).
#' @param dados O data.frame original contendo as variáveis do modelo.
#' @param nome_y Uma string com o nome da variável dependente na escala original (nível).
#' @param novos_dados Opcional. Um data.frame com novos valores para prever.
#' @param conf_level Nível de confiança para o intervalo (padrão 0.95).
#'
#' @details
#' Quando prevemos y em um modelo log-nível, exp(log_y_hat) é um estimador
#' enviesado da média de y. Esta função calcula o Alpha Til (Wooldridge)
#' através de uma regressão de y sobre m_hat sem intercepto para corrigir esse viés.
#'
#' @return Um \code{data.frame} contendo os valores reais, previstos com correção,
#' intervalos de confiança e erro padrão.
#'
#' @export
variavel_dependente_log <- function(
  modelo_log,
  dados,
  nome_y,
  novos_dados = NULL,
  conf_level = 0.95
) {
  # 1. Extração robusta da amostra original
  index_utilizado <- names(residuals(modelo_log))
  y_real_orig <- dados[index_utilizado, nome_y]
  log_y_hat_orig <- fitted(modelo_log)
  u_hat_orig <- residuals(modelo_log)
  m_hat_orig <- exp(log_y_hat_orig)

  # 2. Fatores de Correção (Calculados na Amostra)
  alpha_0_tilde <- as.numeric(coef(lm(y_real_orig ~ 0 + m_hat_orig)))

  # 3. Predição (Amostra vs Novos Dados)
  if (is.null(novos_dados)) {
    pred_obj <- predict(modelo_log, se.fit = TRUE)
    y_real_out <- y_real_orig
  } else {
    pred_obj <- predict(modelo_log, newdata = novos_dados, se.fit = TRUE)
    y_real_out <- rep(NA, nrow(novos_dados))
  }

  # 4. Cálculo de Intervalo de Confiança
  t_critico <- qt((1 + conf_level) / 2, df = modelo_log$df.residual)
  log_upper <- pred_obj$fit + t_critico * pred_obj$se.fit
  log_lower <- pred_obj$fit - t_critico * pred_obj$se.fit

  # 5. Aplicação das Correções
  m_hat <- exp(pred_obj$fit)
  y_previsto_final <- alpha_0_tilde * m_hat

  ic_lower <- alpha_0_tilde * exp(log_lower)
  ic_upper <- alpha_0_tilde * exp(log_upper)

  # 6. Relatório de Performance
  if (is.null(novos_dados)) {
    r2_original <- cor(y_real_out, y_previsto_final)^2
    cat("\n--- Diagnóstico do Modelo (Wooldridge) ---\n")
    cat("Fator Alpha Til (Wooldridge):", round(alpha_0_tilde, 4), "\n")
    cat("R-Quadrado (Nível):          ", round(r2_original, 4), "\n")
  }

  # 7. Retorno (Mantive Log_Ajustado para facilitar diagnósticos)
  return(data.frame(
    Real = y_real_out,
    Previsto_Wooldridge = y_previsto_final,
    IC_Inferior = ic_lower,
    IC_Superior = ic_upper,
    Log_Ajustado = pred_obj$fit,
    Erro_Padrao_Log = pred_obj$se.fit,
    Previsao_Ingenua = m_hat
  ))
}
