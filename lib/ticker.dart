class Ticker{
  Stream<int> ticker ({int ticks}){
    
   return Stream.periodic(Duration(seconds: 1), (x)=> ticks - x - 1 )
        .take(ticks);
    
  }
}