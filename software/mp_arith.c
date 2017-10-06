

/*
 * mp_arith.c
 *
 */
#include <stdint.h>
// Calculates res = a + b.
// a and b represent large integers stored in uint32_t arrays
// a and b are arrays of size elements, res has size+1 elements
void mp_add(uint32_t *a, uint32_t *b, uint32_t *res, uint32_t size)
{
        uint32_t l_i32carry=0;
        uint32_t i;
        uint64_t buf_res=0;
        for(i=0;i<size;i++)
        {
            buf_res = (uint64_t)a[i] + (uint64_t)b[i] + (uint64_t)l_i32carry;
            l_i32carry=buf_res >>32;
            res[i]=(uint32_t)buf_res;
        }
        res[size]=l_i32carry;

}

// Calculates res = a - b.
// a and b represent large integers stored in uint32_t arrays
// a, b and res are arrays of size elements
void mp_sub(uint32_t *a, uint32_t *b, uint32_t *res, uint32_t size)
{
    uint64_t l_i32carry=0;
    uint32_t i;
    uint64_t buf_res=0;
    for(i=0;i<size;i++)
    {
        buf_res= (uint64_t)a[i] - (uint64_t)b[i] + (uint64_t)l_i32carry;
        if (buf_res >= 0x8000000000000000)
            l_i32carry = -1;
        else
            l_i32carry = 0;
        res[i]=(uint32_t)buf_res;
    }

}

// Calculates res = (a + b) mod N.
// a and b represent operands, N is the modulus. They are large integers stored in uint32_t arrays of size elements
void mod_add(uint32_t *a, uint32_t *b, uint32_t *N, uint32_t *res, uint32_t size)
{
	uint32_t sum_ab[size+1];
        mp_add(a,b,sum_ab,size+1); //find the sum of a and b. Note that the size of the sum can be 'size+1'

        uint32_t i=0; //some array index
        //because we will be re-using the substract module created above, we need to make 'N' the same dimension as the sum of a and b.
        uint32_t N_extended[size+1];
        uint32_t res_extended[size+1]; //although its known that the final result will be dimension 'size', but the substract operation works on 'size+1' arrays and the result is
                                       //also an array of dimension 'size+1'
                                       //To avoid any memory over-write, the result is going to be stored in an array called res_extended
        uint32_t result_found=0;
        uint32_t are_equal=0;
        for(i=0;i<size;i++)
                N_extended[i]=N[i];
        N_extended[size]=0; //filling the last register of N_extended with zero

        //if the sum has a carry, it clearly means that the sum(a,b) > N
        if(sum_ab[size]>0)
        {
                mp_sub(sum_ab,N_extended,res_extended,size+1);
                result_found=1;
                for(i=0;i<size;i++)
                        res[i]=res_extended[i];

        }
        else
        {
                for( i=size-1;i--;i=0)
                {
                        if(sum_ab[i]>N[i])
                        {
                                mp_sub(sum_ab,N,res,size);
                                //since we can substract at most once, we need to set varible 'result_found'=1;
                                result_found=1;
                                break;
                        }

                }

        }
        //if the result has not been found till now, then it can mean two things: one that the modulus is zero, or that sum(ab)<N, in which case the result will be sum(a,b)
        if(result_found==0)
        {
                //check whether the two numbers are equal or not
                are_equal=1;
                for(i=0;i<size;i++)
                        if(sum_ab[i]!=N[i])
                                are_equal=0;
                if(are_equal==1)
                        for(i=0;i<size;i++)
                                res[i]=0;
                else
                        mp_sub(sum_ab,N,res,size);
        }



}

// Calculates res = (a - b) mod N.
// a and b represent operands, N is the modulus. They are large integers stored in uint32_t arrays of size elements
void mod_sub(uint32_t *a, uint32_t *b, uint32_t *N, uint32_t *res, uint32_t size)
{

}

