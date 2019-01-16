unit personactns;

{$mode objfpc}{$H+}

interface

uses
  jTableActns, personobjs;

type

  { TPersonListAction }

  TPersonListAction = class(specialize TjTableGListAction<TPersonOpf, TPerson>)
  end;

  { TPersonCreateAction }

  TPersonCreateAction = class(specialize TjTableGCreateAction<TPersonOpf, TPerson>)
  end;

  { TPersonUpdateAction }

  TPersonUpdateAction = class(specialize TjTableGUpdateAction<TPersonOpf, TPerson>)
  end;

  { TPersonDeleteAction }

  TPersonDeleteAction = class(specialize TjTableGDeleteAction<TPersonOpf, TPerson>)
  end;

implementation

initialization
  TPersonListAction.Register('/personlist');
  TPersonCreateAction.Register('/personcreate');
  TPersonUpdateAction.Register('/personupdate');
  TPersonDeleteAction.Register('/persondelete');

end.
