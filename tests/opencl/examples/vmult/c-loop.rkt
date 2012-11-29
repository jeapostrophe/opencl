#lang superc
(require racket/unsafe/ops)

(define loop (get-ffi-obj-from-this 'loop (_fun _int _pointer -> _void)))

(define HOW-MANY (read))
(define the-vector (malloc _float HOW-MANY 'raw))

(for ([i (in-range HOW-MANY)])
  (ptr-set! the-vector _float i (read)))
  
(time
 (loop HOW-MANY the-vector))

(free the-vector)

@c{
 void loop (int how_many, float *input) {
  int i;
  for (i = 0; i < how_many; i++) {
   input[i] = input[i] * input[i];
  }
  return;
 }
}
