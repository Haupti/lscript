(def tm (load-module "testmodule.l"))

((tm 'hello) "steve")
((tm 'hello) "steve")
((tm 'hello) "steve")
((tm 'hello) "steve")

(out (str-to-num "1.2"))

(out (env-get "HOME"))
(out (to-str (args-get)))
