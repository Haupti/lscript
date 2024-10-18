(def tm (load-module "testmodule.l"))

((tm 'hello) "steve")
((tm 'hello) "steve")
((tm 'hello) "steve")
((tm 'hello) "steve")

(out (str-concat "read data: '" (file-read "res/testmodule.l") "'"))
