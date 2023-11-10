
validateGeneratorTypeId() {
    local _generatorType=$1

    case "$_generatorType" in
    DollarRANDOM)
        return 0
        ;;
    randCLA)
        return 0
        ;;
    URODd2)
        return 0
        ;;
    URODd4)
        return 0
        ;;
    URODd8)
        return 0
        ;;
    URODf4)
        return 0
        ;;
    URODf8)
        return 0
        ;;
    URODf16)
        return 0
        ;;
    URODo2)
        return 0
        ;;
    URODo4)
        return 0
        ;;
    URODo8)
        return 0
        ;;
    URODu2)
        return 0
        ;;
    URODu4)
        return 0
        ;;
    URODu8)
        return 0
        ;;
    URODx2)
        return 0
        ;;
    URODx4)
        return 0
        ;;
    URODx8)
        return 0
        ;;
    *)
        return 1
        ;;
    esac
}


if validateGeneratorTypeId DollarRANDOM
then
    echo "1 good."
else
    echo "1 bad."
fi

if validateGeneratorTypeId NOTTHIS
then
    echo "2 good."
else
    echo "2 bad."
fi

if validateGeneratorTypeId URODx8
then
    echo "3 good."
else
    echo "3 bad."
fi
