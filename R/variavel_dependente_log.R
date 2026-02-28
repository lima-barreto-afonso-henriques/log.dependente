#' Previsão Corrigida para Modelos com Variável Dependente em Log
#'
#' Esta função implementa os procedimentos de correção de viés de Wooldridge
#' para modelos de regressão linear onde a variável dependente foi transformada
#' usando logaritmo natural. Ela fornece as previsões "ingênuas" e as corrigidas
#' pelos métodos de Alpha Chapéu (Média) e Alpha Til (Média de Wooldridge).
#'
#' @param modelo_log Um objeto de classe \code{lm} estimado com log(y).
#' @param dados O data.frame original contendo as variáveis do modelo.
#' @param nome_y Uma string com o nome da variável dependente na escala original (nível).
#'
#' @details
#' Quando prevemos y em um modelo log-nível, exp(log_y_hat) é um estimador
#' enviesado da média de y. Esta função calcula:
#' \enumerate{
#'   \item \strong{Alpha_0_hat}: Baseado na média da exponencial dos resíduos.
#'   \item \strong{Alpha_0_tilde}: Baseado na regressão de y sobre exp(log_y_hat) sem intercepto.
#' }
#'
#' @return Um \code{data.frame} contendo os valores reais, log ajustado,
#' erro padrão do log, resíduos e as previsões corrigidas.
#'
#' @examples
#' \dontrun{
#' library(wooldridge)
#' data(hprice2)
#' mod <- lm(log(price) ~ log(nox) + rooms, data = hprice2)
#' resultados <- variavel_dependente_log(mod, hprice2, "price")
#' head(resultados)
#' }
#'
#' @export
variavel_dependente_log <- function(modelo_log, dados, nome_y) {
  # 1. Obter previsões (log y hat) e erros padrão para o log(y)
  predicao_obj <- predict(modelo_log, se.fit = TRUE)
  log_y_hat <- predicao_obj$fit
  se_log_y_hat <- predicao_obj$se.fit
  u_hat <- residuals(modelo_log)
  y_real <- dados[[nome_y]]

  # 2. Calcular m_hat (previsão ingênua: exp(log_y_hat))
  m_hat <- exp(log_y_hat)

  # --- CÁLCULO DOS FATORES DE CORREÇÃO ---

  # MÉTODO A: Alpha_0 Chapéu (Média da exponencial dos resíduos)
  alpha_0_hat <- mean(exp(u_hat))

  # MÉTODO B: Alpha_0 Til (Wooldridge - Regressão sem intercepto)
  alpha_0_tilde <- as.numeric(coef(lm(y_real ~ 0 + m_hat)))

  # --- GERAR PREVISÕES FINAIS ---
  y_previsto_A <- alpha_0_hat * m_hat
  y_previsto_B <- alpha_0_tilde * m_hat

  # --- RELATÓRIO NO CONSOLE ---
  r2_final <- cor(y_real, y_previsto_B)^2

  cat("\n--- Resultados da Correção (Escala Original) ---\n")
  cat("Alpha_0 Chapéu (Média): ", round(alpha_0_hat, 4), "\n")
  cat("Alpha_0 Til (Wooldridge):", round(alpha_0_tilde, 4), "\n")
  cat("R² na escala original:   ", round(r2_final, 4), "\n")

  # Retorna o Dataframe Organizado
  return(data.frame(
    Real = y_real,
    Log_Ajustado = log_y_hat,
    Erro_Padrao_Log = se_log_y_hat,
    Residuos = u_hat,
    Prev_Ingenua = m_hat,
    Prev_Metodo_A = y_previsto_A,
    Prev_Metodo_B = y_previsto_B
  ))
}
