# UTF-8 のバイトの並びからトークン数を概算する
# LC_ALL=C で動かすこと

{
  s = $0
  n = length(s)
  t = s; a = gsub(/[\302-\337]/, "", t)
  t = s; b = gsub(/[\340-\357]/, "", t)
  t = s; c = gsub(/[\360-\364]/, "", t)
  cont = a + b * 2 + c * 3
  ascii = n - a - b - c - cont
  if (ascii < 0) ascii = 0
  tok += ascii / 4 + a * 0.5 + b + c * 2.5 + 0.25
}

END { printf "%d\n", tok + 0.5 }
