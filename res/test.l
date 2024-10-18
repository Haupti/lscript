(def tm (load-module "testmodule.l"))

((tm 'hello) "steve")
((tm 'hello) "steve")
((tm 'hello) "steve")
((tm 'hello) "steve")

(def tm2 (load-module "testmodule.l"))

((tm2 'hello) "steve")
((tm2 'hello) "steve")
((tm2 'hello) "steve")
((tm2 'hello) "steve")
