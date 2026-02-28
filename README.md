# log.dependente 📈

O pacote **log.dependente** fornece ferramentas para a correção de viés em previsões de modelos de regressão linear onde a variável dependente está em escala logarítmica ($\log y$). 

A implementação é baseada nos métodos discutidos por Jeffrey Wooldridge em seu livro *Introductory Econometrics*.

## 🧐 O Problema
Ao estimar um modelo $\log(y) = \beta_0 + \beta_1x + u$ e aplicar a função exponencial para retornar à escala original ($\exp(\widehat{\log y})$), obtemos um estimador da mediana, e não da média de $y$. Em dados com assimetria, como preços e salários, isso resulta em uma **subestimação sistemática** do valor real.

## 🚀 Solução
Este pacote implementa o **Procedimento de Wooldridge**, utilizando fatores de correção ($\alpha$) para garantir que as previsões na escala original (nível) sejam consistentes.



### Funcionalidades:
- **Previsão na Amostra e Extra-amostra**: Suporte para novos dados via argumento `novos_dados`.
- **Método A**: Correção via média simples dos resíduos ($\hat{\alpha}_0$).
- **Método B (Recomendado)**: Correção via estimador de Wooldridge ($\tilde{\alpha}_0$) através de regressão sem intercepto.
- **Intervalos de Confiança**: Cálculo automático de ICs na escala original (nível).
- **Métricas de Ajuste**: Cálculo do $R^2$ na escala original para comparação de modelos.

## 🛠 Instalação

Você pode instalar a versão de desenvolvimento diretamente do GitHub:

```r
# install.packages("devtools")
devtools::install_github("lima-barreto-afonso-henriques/log.dependente")


📖 Exemplo de Uso

library(log.dependente)
library(wooldridge)

# 1. Estimar um modelo log-log ou log-nível
data(hprice2)
modelo <- lm(log(price) ~ log(nox) + rooms, data = hprice2)

# 2. Corrigir as previsões da amostra
resultados <- variavel_dependente_log(modelo, hprice2, "price")
head(resultados)

# 3. Prever para um novo cenário (ex: casa com nox=5 e 6 quartos)
novas_casas <- data.frame(nox = 5, rooms = 6)
previsao_nova <- variavel_dependente_log(modelo, hprice2, "price", novos_dados = novas_casas)
print(previsao_nova)


📚 Referência Bibliográfica
Wooldridge, Jeffrey M. Introductory Econometrics: A Modern Approach. Cengage Learning.