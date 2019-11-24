type form =  True | False | Var of char | Conj of form * form | Dysj of form * form | Cond of form * form
type pre = Est of form | PreE of form * rule | PreR of rule
and rule = Rule of pre list * form;;

let test = Rule(
  [
    PreE(
      Conj( Var('p'), Cond( Var('p'), Var('q') ) ),
      Rule(
        [
          PreR(
            Rule(
              [
                Est(Conj( Var('p'), Cond( Var('p'), Var('q') ) ))
              ],
              Var('p')
            )
          );
          PreR(
            Rule(
              [
                Est(Conj( Var('p'), Cond( Var('p'), Var('q') ) ))
              ],
              Cond( Var('p'), Var('q'))
            )
          )
        ],
        Var('q')
      )
    )
  ],
  Cond( Conj( Var('p'), Cond( Var('p'), Var('q') ) ), Var('q') )
);;