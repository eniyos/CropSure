Rondel by fontzz

variable/  one file, every weight from 100 to 900
static/    nine fixed weights (Thin to Black)
web/       WOFF2 for the web

CSS:
@font-face {
  font-family: "Rondel";
  src: url("Rondel[wght].woff2") format("woff2");
  font-weight: 100 900;
  font-display: swap;
}
