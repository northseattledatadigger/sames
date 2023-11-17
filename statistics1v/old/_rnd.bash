OutputDecimalPrecision=1

_rnd() {
    _inNo="$1"

    # NOTE of caution:  This ONLY works with fairly small exponents, as the number
    # overflows otherwise.
    local buffer="scale=30;$_inNo"
    if [[ $_inNo =~ [0-9][Ee][+-][0-9] ]]
    then
        buffer="scale=30;$(echo $_inNo | sed 's/[Ee][+-]*/*10^/')"
    fi
    case $OutputDecimalPrecision in
    0)
        printf %.0f $(echo "$buffer+0.5" | bc -l)
        ;;
    1)
        printf %.1f $(echo "$buffer+0.05" | bc -l)
        ;;
    2)
        printf %.2f $(echo "$buffer+0.005" | bc -l)
        ;;
    3)
        printf %.3f $(echo "$buffer+0.0005" | bc -l)
        ;;
    4)
        printf %.4f $(echo "$buffer+0.00005" | bc -l)
        ;;
    5)
        printf %.5f $(echo "$buffer+0.000005" | bc -l)
        ;;
    6)
        printf %.6f $(echo "$buffer+0.0000005" | bc -l)
        ;;
    7)
        printf %.7f $(echo "$buffer+0.00000005" | bc -l)
        ;;
    8)
        printf %.8f $(echo "$buffer+0.000000005" | bc -l)
        ;;
    9)
        printf %.9f $(echo "$buffer+0.0000000005" | bc -l)
        ;;
    *)
        echo -n $buffer
        ;;
    esac
}

echo "trace 1"
result=$(_rnd $1)
echo "result:  $result"
