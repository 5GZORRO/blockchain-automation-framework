if [ ! -f build/.env ]
then
  export $(cat build/.env | xargs)
fi