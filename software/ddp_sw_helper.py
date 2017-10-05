
from random import randrange

def xgcd(b, n):
    x0, x1, y0, y1 = 1, 0, 0, 1
    while n != 0:
        q, b, n = b // n, n, b % n
        x0, x1 = x1, x0 - q * x1
        y0, y1 = y1, y0 - q * y1
    return  b, x0, y0

def mulinv(b, n):
    g, x, _ = xgcd(b, n)
    if g == 1:
        return x % n

def mp_add(a, b):
    return a + b

def mp_sub(a, b):
    return a - b

def mod_mp_add(a, b, N):
    return (a + b) % N

def mod_mp_sub(a, b, N):
    return (a - b) % N

# Performs montgomery multiplication given inputs a, b, base r and modulus N
def mont_mul(a, b, r, N):
    r_inv = mulinv(r, N)
    return (a * b * r_inv) % N

# Same as previous function
#def mont_mul_gmp(a, b, r, N):
#    r_inv = invert(r, N)
#    return (a * b * r_inv) % N

# Generates c code for uint array that is initialized with with value of first argument
# Second argument is the name of array you wish to use. Default is 'a'
# Third argument is size in 32-bit word of the first argument. Default is 64 which translates to 2048-bit number. 
# Generated array always has size elements, meaning that high index elements will be zero if first argument is to small
def print2array(a, name='a', size=32):
    out = 'uint {}[{:d}] = {{'.format(name, size)
    for i in range(size):
        out += '0x{:08x}'.format(a & 0xFFFFFFFF)
        a >>= 32
        out += ', ' if i<(size - 1) else '};'
    print (out)

#Prints out the first argument in hex form without leading zeros
def print_result(a, name='a', size=32):
    if a >= 0:
        print(name + ' = ' + '0x{:x}'.format(a)) 
    else:
        print(name + ' = ' + '0x{:x}'.format(a % 2**(size * 32)))



def main():

    N1 = 0x83a01efeed17377f8d00abfe472c0bea908293dd1a568588141ad5860b4391e87951dd0cc7b55eaefeef4c6b66a3bb9b46eeae2f249ee0f8c8710dc69f84d87b7ae59036e8938df6b17c35989f23e5c7c1c1da45a43ed7371248f3ed833d9b82099d6d7020478120c10fa093f93f738c6f5326c96c55dd055d78aa984aeeb107 
    N2 = 0x86ad49526b079c2c695e5d7734b9220f2fd12fc8e9041ac4f1856267fd772f68f221e0fdd97d05cef664e91d61561df62485755e22f7165a94711c9e8e47420e8f6bd9e26b67432861419fe8dd42688c8449d487ac3f28b15d635e1708fd96bfd278192cd3c65a9b3bdf79cf028def7e450ca4b0e6f266e408e49be7c6df4c85 
    N3 = 0xb5d738a0bae335254b71a0e254f0f9b95cfa78874d51689ce2fe1c985173de8cb807a6ae8ce3e7f144fdd142d199da8f7de168b79439c77f633354b3a812c547330e7700b451c21d5ab2133808a64bd1a2ebe291d893feb029fb66a2ba07c851a35e54c56b785070947f45f77582491e9a02f06b95d708c11a3042d4575bb461 
    #Ex 2: Multiprecision arithmetic. Comment this out if you dont want to run this code
    a = 0x63a0a0cbe8fc5934c6b030aec34620c53db59a361121beec10bce41c5cdf77c79e778cef42e3f8b9610691127ea2490e87acb6587357f72cf0384e034089c0503e6ee26057ebc43d2e6c1dbd724c03a48cb6fba7c4f11a2e1eafc4c3493ee595578fde168811c17af67c106146bf484858ab6bf4edfa617d4ae251f1f484e847
    b = 0x65f89f9f615213c445396d719b6d93e58d0d4f3757decf64f16243f0814c53dc6e54b058201040c63ce537cade4fffa0df87cfe57923cb60d29e0870a42c03b498af9011b61c1c8d7126650d6f42204d4373912f1e95cdcc10e8ab5460ef0e2355c85f244119e1e918def18b9ece9e1b07f21d6dfb09354de91d3becfeb1b9f4

    print ('Exercise 2\n\n\n')
    #These are only used to generate c array code for large numbers. They are not needed for performing calculations
    print2array(a, 'a', 32) 
    print2array(b, 'b', 32) 
    print2array(N1, 'N', 32) 

    #Printing result and operands
    print_result(a, 'a')
    print_result(b, 'b')
    print_result(N1, 'N')
    print ('\n\n\n')
    print_result(mp_add(a, b), '(a + b)' )
    print ('\n\n\n')
    print_result(mp_sub(a, b), '(a - b)' )


    # Ex 2: Modular arithmetic. Comment this out if you don't want to run this code
    #These are only used to generate c array code for large numbers. They are not needed for performing calculations

    #Printing result and operands
    print ('\n\n\n')
    print_result(mod_mp_add(a, b, N1), '(a + b) mod N' )
    print ('\n\n\n')
    print_result(mod_mp_sub(a, b, N1), '(a - b) mod N')
    print ('\n\n\n')

'''    #Ex 3 and 4: Montgomery multiplication. Comment this out if you don't want to run this code

    print ('Exercise 3\n\n\n')
    #a = randrange(N1)
    #b = randrange(N1)

    r = 2**1024

    c = mont_mul(a, b, r, N1)
    print2array(a, 'a', 32)
    print2array(b, 'b', 32)
    print2array(N1, 'N', 32)
    print2array((r - mulinv(N1, r)), 'n_prime', 32) 

    print ('\n\n\n')
    print_result(c, 'mont_mul')
    print ('\n\n\n')

    a = 0x07d92c14c52a6c88c90096c43c80aecf917d544c69f174f6dfede44cb60ee4dcf24a2910aa396499489963822514307723d635bb419a784ea328f0365dd5313dedaf8b6b024897326550e48edb438313c7ed29ebfefeb38ed51c806400c35266ce2058bbdad8575e748f18feac500fe05fe4fd66cd340e16f2e5f53895401e33
    b = 0x1f8042e7747a7bb06ccff27def7f7adeaa9589fbf833b81ca4b160f1d7532d14fdf337de34d884aa25167785edef232c4332989f32edcdb90a836d5e66dc5f67de5b7e6f51f0df683b74cdb222704082adcae3e65d05fed8ac5a2199240e4293c0ed3b8172096da0b62173f6aec10e86395c2b8b4a7230d6c765f25ad7040630 
    #a = randrange(N2)
    #b = randrange(N2)

    c = mont_mul(a, b, r, N2)
    print2array(a, 'a', 32)
    print2array(b, 'b', 32)
    print2array(N2, 'N', 32)
    print2array((r - mulinv(N2, r)), 'n_prime', 32) 

    print ('\n\n\n')
    print_result(c, 'mont_mul')
    print ('\n\n\n')

    a = 0x2c261c9b607fc341191a0cc0c0a7108c046d10524135e9f9bd13b6fd7420341993df7baef489dab2f6a0e49f82f4820eaba36ace21c0b44a651c9e4657dc78371c1a680751a66eb0fabbcfe3520fa2fe3178b33b4210ad08f0af88c6465ab66a04b6f5a721c3a9a574150080873a8d9d9c028fdefef81247b3270d274b0afbba 
    b = 0x63a68886b5118fec8ac21ffd2982780eedf5af4488da4e102a7f05475dfdb200df354cd4d5d7c3454a15cd7c7793f6b9c2281d7e634a379e9e56065e67498835fd3b09118026f87787b90b9bb4e0aae587069825db0242ba51c28d81c643edb77b52c351839b99e30abf48a4179e24660cc1e17c825c7977925c0577f1d2b3e2
    #a = randrange(N3)
    #b = randrange(N3)

    c = mont_mul(a, b, r, N3)
    print2array(a, 'a', 32)
    print2array(b, 'b', 32)
    print2array(N3, 'N', 32)
    print2array((r - mulinv(N3, r)), 'n_prime', 32) 

    print ('\n\n\n')
    print_result(c, 'mont_mul')
    print ('\n\n\n')


    #print('Result is 0x{:0512x}'.format(c))
'''
if __name__ == '__main__':
    main()
